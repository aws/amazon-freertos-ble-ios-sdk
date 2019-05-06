import AWSIoT
import CoreBluetooth

public class AmazonFreeRTOSDevice: NSObject {

    public var peripheral: CBPeripheral
    public var advertisementData: [String: Any]?
    public var RSSI: NSNumber?

    public var reconnect = false
    public var certificateId: String?
    public var credentialsProvider: AWSCredentialsProvider?

    public var afrVersion: String?
    public var brokerEndpoint: String?
    public var mtu: Int?

    public var savedNetworks: [ListNetworkResp] = []
    public var scanedNetworks: [ListNetworkResp] = []

    public var txLotDatas: [String: Data] = [:]
    public var rxLotDataQueues: [String: [Data]] = [:]

    public init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        super.init()
    }

    public func reset() {

        removeIoTDataManager()

        txLotDatas.removeAll()
        rxLotDataQueues.removeAll()

        afrVersion = nil
        brokerEndpoint = nil
        mtu = nil

        savedNetworks.removeAll()
        scanedNetworks.removeAll()
    }

    public func registerIoTDataManager(connect: Connect) -> Bool {

        let brokerEndpointParts = connect.brokerEndpoint.split(separator: ".")
        guard let endpoint = AWSEndpoint(urlString: "https://\(connect.brokerEndpoint)"), brokerEndpointParts.count > 2, let serviceConfiguration = AWSServiceConfiguration(region: String(brokerEndpointParts[2]).aws_regionTypeValue(), endpoint: endpoint, credentialsProvider: credentialsProvider) else {
            return false
        }
        AWSIoTDataManager.register(with: serviceConfiguration, forKey: peripheral.identifier.uuidString)
        updateIoTDataManager()
        return true
    }

    public func removeIoTDataManager() {
        AWSIoTDataManager(forKey: peripheral.identifier.uuidString).disconnect()
        AWSIoTDataManager.remove(forKey: peripheral.identifier.uuidString)

        txLotDatas.removeValue(forKey: AmazonFreeRTOSGattService.MqttProxy.uuidString)
        rxLotDataQueues.removeValue(forKey: AmazonFreeRTOSGattService.MqttProxy.uuidString)
    }

    public func updateIoTDataManager() {
        var userMetaData = ["AmazonFreeRTOSSDK": "iOS", "AmazonFreeRTOSSDKVersion": AmazonFreeRTOS.SDKVersion]
        if let afrVersion = afrVersion {
            userMetaData["AmazonFreeRTOSLibVersion"] = afrVersion
        }
        AWSIoTDataManager(forKey: peripheral.identifier.uuidString).updateUserMetaData(userMetaData)
    }
}

extension AmazonFreeRTOSDevice {

    /**
     Connect to the AmazonFreeRTOS device.

     - Parameters:
     - reconnect: AmazonFreeRTOS device should auto reconnect on non-explicit disconnect.
     - certificateId: The certificateId used to connect. see: https://github.com/awslabs/aws-sdk-ios-samples/tree/master/IoT-Sample/Swift
     - credentialsProvider: The credentialsProvider used to connect like AWSMobileClient for Cognito.
     - Precondition: central is ready and device must be disconnected, otherwise it will be ignored.
     */
    public func connect(reconnect: Bool, certificateId: String? = nil, credentialsProvider: AWSCredentialsProvider? = nil) {
        self.reconnect = reconnect
        self.certificateId = certificateId
        self.credentialsProvider = credentialsProvider
        if peripheral.state == .disconnected {
            AmazonFreeRTOSManager.shared.central?.connect(peripheral, options: nil)
        }
    }

    /**
     Disconnect from the AmazonFreeRTOS device.

     - Precondition: central is ready and device must be connected, otherwise it will be ignored.
     */
    public func disconnect() {
        reconnect = false
        if peripheral.state == .connected {
            AmazonFreeRTOSManager.shared.central?.cancelPeripheralConnection(peripheral)
        }
    }
}

// Device Info Service

extension AmazonFreeRTOSDevice {

    /// Get afrVersion of the AmazonFreeRTOS device.
    public func getAfrVersion() {

        AmazonFreeRTOSManager.shared.debugPrint("[\(peripheral.identifier.uuidString)] ↓ get afrVersion")

        guard let characteristic = peripheral.serviceOf(uuid: AmazonFreeRTOSGattService.DeviceInfo)?.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.AfrVersion) else {
            AmazonFreeRTOSManager.shared.debugPrint("[\(peripheral.identifier.uuidString)][ERROR] DeviceInfo service or AfrVersion characteristic doesn't exist")
            return
        }
        peripheral.readValue(for: characteristic)
    }

    /// Get mqtt broker endpoint of the AmazonFreeRTOS device.
    public func getBrokerEndpoint() {

        AmazonFreeRTOSManager.shared.debugPrint("[\(peripheral.identifier.uuidString)] ↓ get brokerEndpoint")

        guard let characteristic = peripheral.serviceOf(uuid: AmazonFreeRTOSGattService.DeviceInfo)?.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.BrokerEndpoint) else {
            AmazonFreeRTOSManager.shared.debugPrint("[\(peripheral.identifier.uuidString)][ERROR] DeviceInfo service or BrokerEndpoint characteristic doesn't exist")
            return
        }
        peripheral.readValue(for: characteristic)
    }

    /// Get BLE mtu of the AmazonFreeRTOS device.
    public func getMtu() {

        AmazonFreeRTOSManager.shared.debugPrint("[\(peripheral.identifier.uuidString)] ↓ get mtu")

        guard let characteristic = peripheral.serviceOf(uuid: AmazonFreeRTOSGattService.DeviceInfo)?.characteristicOf(uuid: AmazonFreeRTOSGattCharacteristic.Mtu) else {
            AmazonFreeRTOSManager.shared.debugPrint("[\(peripheral.identifier.uuidString)][ERROR] DeviceInfo service or Mtu characteristic doesn't exist")
            return
        }
        peripheral.readValue(for: characteristic)
    }
}

// Network Config Service

extension AmazonFreeRTOSDevice {

    /**
     List saved and scanned wifi networks of device. Wifi networks are returned one by one, saved wifi ordered by priority and scanned wifi ordered by signal strength (rssi).

     - Parameter listNetworkReq: The list network request.
     */
    public func listNetwork(_ listNetworkReq: ListNetworkReq) {

        // reset networks list for the peripheral

        savedNetworks.removeAll()
        scanedNetworks.removeAll()

        AmazonFreeRTOSManager.shared.listNetwork(peripheral, listNetworkReq: listNetworkReq)
    }

    /**
     Save wifi network to device.

     - Parameter saveNetworkReq: The save network request.
     */
    public func saveNetwork(_ saveNetworkReq: SaveNetworkReq) {
        AmazonFreeRTOSManager.shared.saveNetwork(peripheral, saveNetworkReq: saveNetworkReq)
    }

    /**
     Edit wifi network of device. Currently only support priority change.

     - Parameter editNetworkReq: The edit network request.
     */
    public func editNetwork(_ editNetworkReq: EditNetworkReq) {
        AmazonFreeRTOSManager.shared.editNetwork(peripheral, editNetworkReq: editNetworkReq)
    }

    /**
     Delete saved wifi network from device.

     - Parameter deleteNetworkReq: The delete network request.
     */
    public func deleteNetwork(_ deleteNetworkReq: DeleteNetworkReq) {
        AmazonFreeRTOSManager.shared.deleteNetwork(peripheral, deleteNetworkReq: deleteNetworkReq)
    }
}
