//
//  MyNSObject.swift
//  CBORSwift
//
//  Created by Hassan Shahbazi on 2018-05-15.
//  Copyright © 2018 Hassan Shahbazi. All rights reserved.
//

import Foundation

public class NSByteString: NSObject {
    private var value: String = ""

    public init(_ value: String) {
        super.init()
        self.value = value
    }

    public func stringValue() -> String {
        return value
    }

    @objc internal override func encode() -> String {
        var byteArray = [UInt8]()
        for offset in stride(from: 0, to: value.count, by: 2) {
            let byte = value[offset ..< offset + 2].hex_decimal
            byteArray.append(UInt8(byte))
        }
        let encodedArray = Encoder.prepareByteArray(major: .major2, measure: byteArray.count)
        let headerData = Data(encodedArray).binary_decimal.hex
        let byteData = Data(byteArray).hex

        return headerData.appending(byteData)
    }
}

public class NSSimpleValue: NSObject {
    private static let FALSECode: UInt8 = 0x14
    private static let TRUECode: UInt8 = 0x15
    private static let NILCode: UInt8 = 0x16
    private var value: Bool?

    public init(_ value: NSNumber?) {
        super.init()
        self.value = value?.boolValue
    }

    public func stringValue() -> Bool {
        return value!
    }

    @objc internal override func encode() -> String {
        var byte = NSSimpleValue.NILCode
        if value != nil {
            byte = (value!) ? NSSimpleValue.TRUECode : NSSimpleValue.FALSECode
        }
        var encodedArray = Encoder.prepareByteArray(major: .major7, measure: 0)
        encodedArray = [UInt8](encodedArray[0 ..< 3])

        var byteArray = Data([byte]).hex.hex_binary
        byteArray = [UInt8](byteArray[3 ..< byteArray.count])

        encodedArray.append(contentsOf: byteArray)
        return Data(encodedArray).binary_decimal.hex
    }

    public class func decode(header: Int) -> NSNumber? {
        let header = header + Int(0x14)

        if header == FALSECode {
            return NSNumber(value: false)
        }
        if header == TRUECode {
            return NSNumber(value: true)
        }
        return nil
    }
}

public class NSTag: NSObject {
    private var tag: Int! = -1
    private var value: NSObject!

    public init(tag: Int, _ value: NSObject) {
        super.init()

        self.tag = tag
        self.value = value
    }

    @objc internal override func encode() -> String {
        if tag > 0 {
            let encodedArray = Encoder.prepareByteArray(major: .major6, measure: tag)
            let headerData = Data(encodedArray).binary_decimal.hex
            let encodedValue = Data(value.encode()!).hex

            return headerData.appending(encodedValue)
        }
        return ""
    }

    public func tagValue() -> Int {
        return tag
    }

    public func objectValue() -> NSObject {
        return value
    }
}
