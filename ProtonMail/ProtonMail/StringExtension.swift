//
//  StringExtension.swift
//  ProtonMail
//
//  Created by Diego Santiviago on 2/23/15.
//  Copyright (c) 2015 ArcTouch. All rights reserved.
//

import Foundation

extension String {
    
    /**
    String extension check is email valid use the basic regex
    
    :returns: true | false
    */
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        if let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx) as NSPredicate? {
            return emailTest.evaluateWithObject(self)
        }
        return false
    }
    
    /**
    String extension for remove the whitespaces begain&end
    
        Example: 
        " adsf " => "ads"
    
    :returns: trimed string value
    */
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
    }
    
    
    /**
    String extension parse a json string to a list of dict
    
    :returns: [ [String:String] ]
    */
    func parseJson() -> [[String:String]]? {
        var error: NSError?
        if self.isEmpty {
            return [];
        }
        
        let data : NSData! = self.dataUsingEncoding(NSUTF8StringEncoding)
        let decoded = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.MutableContainers, error:  &error) as! [[String:String]]
        return decoded
    }

    
    /**
    String extension split a string by comma
        
    Example:
    "a,b,c,d" => ["a","b","c","d"]
    
    :returns: [String]
    */
    func splitByComma() -> [String] {
        return split(self) {$0 == ","}
    }
    
    
    
    func ln2br() -> String {
        return  self.stringByReplacingOccurrencesOfString("\n", withString:  "<br>") 
    }
    
    
    /**
    String extension formating the Json format contact for forwarding email.
    
    :returns: String
    */
    func formatJsonContact() -> String {
        var lists: [String] = []
        
        let recipients : [[String : String]] = self.parseJson()!
        for dict:[String : String] in recipients {
            let name = dict.getName()
            
            lists.append(dict.getName() + "&lt;\(dict.getAddress())&gt;")
        }
        return ",".join(lists)
    }
    
    /**
    String extension decode some encoded htme tags
    
    :returns: String
    */
    func decodeHtml() -> String {
        var result = self.stringByReplacingOccurrencesOfString("&amp;", withString: "&", options: nil, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&quot;", withString: "\"", options: nil, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#039;", withString: "'", options: nil, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&#39;", withString: "'", options: nil, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&lt;", withString: "<", options: nil, range: nil)
        result = result.stringByReplacingOccurrencesOfString("&gt;", withString: ">", options: nil, range: nil)
        return result
//        let encodedData = self.dataUsingEncoding(NSUTF8StringEncoding)!
//        let attributedOptions : [String: AnyObject] = [
//            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
//            NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding
//        ]
//        let attributedString = NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil, error: nil)!
//        return attributedString.string
    }
    
    func encodeHtml() -> String {
        var result = self.stringByReplacingOccurrencesOfString("&", withString: "&amp;", options: nil, range: nil)
        result = result.stringByReplacingOccurrencesOfString("\"", withString: "&quot;", options: nil, range: nil)
        result = result.stringByReplacingOccurrencesOfString("'", withString: "&#039;", options: nil, range: nil)
        result = result.stringByReplacingOccurrencesOfString("<", withString: "&lt;", options: nil, range: nil)
        result = result.stringByReplacingOccurrencesOfString(">", withString: "&gt;", options: nil, range: nil)
        return result
        
    }
}

