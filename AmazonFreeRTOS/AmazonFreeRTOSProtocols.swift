protocol Encborable {
    func toDictionary() -> NSDictionary
}

protocol Decborable {
    static func toSelf<T: Decborable>(dictionary: NSDictionary) -> T?
}
