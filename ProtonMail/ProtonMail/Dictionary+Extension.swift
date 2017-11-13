//
//  DictionaryExtension.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 7/2/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//

import Foundation

extension Dictionary { //email name
    public func getDisplayName() -> String {    //this function only for the To CC BCC list parsing
        if let key = "Name" as? Key {
            let name = self[key] as? String ?? ""
            if !name.isEmpty {
                return name
            }
        }
        if let key = "Address" as? Key {
            return self[key] as? String ?? ""
        }
        return ""
    }
    
    public func getAddress() -> String {    //this function only for the To CC BCC list parsing
        if let key = "Address" as? Key {
            return self[key] as? String ?? ""
        }
        return ""
    }
    
    public func getName() -> String {    //this function only for the To CC BCC list parsing
        if let key = "Name" as? Key {
            return self[key] as? String ?? ""
        }
        return ""
    }
    
    
    /**
    base class for convert anyobject to a json string
    
    :param: value         AnyObject input value
    :param: prettyPrinted Bool is need pretty format
    
    :returns: String value
    */
    public func JSONStringify(_ prettyPrinted: Bool = false) -> String {
        let options : JSONSerialization.WritingOptions = prettyPrinted ? .prettyPrinted : JSONSerialization.WritingOptions()
        let anyObject: Any = self
        if JSONSerialization.isValidJSONObject(anyObject) {
            do {
                let data = try JSONSerialization.data(withJSONObject: anyObject, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch let ex as NSError {
                PMLog.D("\(ex)")
            }
        }
        return ""
    }
    
}
