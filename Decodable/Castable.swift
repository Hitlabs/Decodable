//
//  Castable.swift
//  Decodable
//
//  Created by Johannes Lund on 2015-09-25.
//  Copyright © 2015 anviking. All rights reserved.
//

import Foundation

public protocol Castable: Decodable {}

extension Castable {
    public static func decode(j: AnyObject) throws -> Self {
        guard let result = j as? Self else {
            let info = DecodingError.Info(object: j)
            throw DecodingError.TypeMismatch(type: j.dynamicType, expectedType: self, info: info)
            
        }
        return result
    }
}

private let numberFormatter: NSNumberFormatter = {
    let f = NSNumberFormatter()
    f.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    return f
}()

private func decodeNumeric<T>(j: AnyObject, primitiveClosure: (number: NSNumber) -> (T)) throws -> T {
    if let result = j as? T {
        return result
    }
    if let string = j as? String, result = numberFormatter.numberFromString(string) {
        return primitiveClosure(number: result)
    }
    let info = DecodingError.Info(object: j)
    throw DecodingError.TypeMismatch(type: j.dynamicType, expectedType: T.self, info: info)
}

extension String: Castable {}
extension Int: Castable {
    public static func decode(j: AnyObject) throws -> Int {
        return try decodeNumeric(j) { $0.integerValue }
    }
}
extension Int64: Castable {
    public static func decode(j: AnyObject) throws -> Int64 {
        return try decodeNumeric(j) { $0.longLongValue }
    }
}
extension Double: Castable {
    public static func decode(j: AnyObject) throws -> Double {
        return try decodeNumeric(j) { $0.doubleValue }
    }
}
extension Bool: Castable {
    public static func decode(j: AnyObject) throws -> Bool {
        return try decodeNumeric(j) { $0.boolValue }
    }
}
extension Dictionary: Castable {}