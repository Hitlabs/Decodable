//
//  Parse.swift
//  Decodable
//
//  Created by Johannes Lund on 2015-08-13.
//  Copyright © 2015 anviking. All rights reserved.
//

import Foundation

public func parse<T>(json: AnyObject, path: [String], decode: (AnyObject throws -> T)) throws -> T {
    
    var object = json
    
    if let lastKey = path.last {
        var path = path
        path.removeLast()
        
        var currentDict = try NSDictionary.decode(json)
        var currentPath: [String] = []
        
        func objectForKey(dictionary: NSDictionary, key: String) throws -> AnyObject {
            guard let result = dictionary[key] else {
                let info = DecodingError.Info(object: dictionary, rootObject: json, path: currentPath)
                throw DecodingError.MissingKey(key: key, info: info)
            }
            return result
        }
        
        for key in path {
            currentDict = try NSDictionary.decode(objectForKey(currentDict, key: key))
            currentPath.append(key)
        }
        
        
        
        object = try objectForKey(currentDict, key: lastKey)
    }
    
    return try catchAndRethrow(json, path) { try decode(object) }
    
}

public func parse<T>(json: AnyObject, path: [String], decode: (AnyObject throws -> T)) throws -> T? {
    
    var object = json
    
    if let lastKey = path.last {
        var path = path
        path.removeLast()
        
        var currentDict = try NSDictionary.decode(json)
        var currentPath: [String] = []
        
        func objectForKey(dictionary: NSDictionary, key: String) -> AnyObject? {
            guard let result = dictionary[key] where !(result is NSNull) else {
                return nil
            }
            return result
        }
        
        for key in path {
            guard let value = objectForKey(currentDict, key: key) else {
                return nil
            }
            currentDict = try NSDictionary.decode(value)
            currentPath.append(key)
        }
        
        guard let o = objectForKey(currentDict, key: lastKey) else {
            return nil
        }
        object = o
    }
    
    return try catchAndRethrow(json, path) { try decode(object) }
    
}

// MARK: - Helpers

func catchAndRethrow<T>(json: AnyObject, _ path: [String], block: Void throws -> T) throws -> T {
    do {
        return try block()
    } catch var error as DecodingError {
        error.info.path = path + error.info.path
        error.info.rootObject = json
        throw error
    } catch let error {
        throw error
    }
}