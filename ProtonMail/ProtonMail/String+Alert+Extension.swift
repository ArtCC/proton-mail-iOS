//
//  String+Alert+Extension.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 7/13/17.
//  Copyright © 2017 ProtonMail. All rights reserved.
//

import Foundation


extension String {
    
    public func alertController() -> UIAlertController {
        let message = self
        return UIAlertController(title: NSLocalizedString("Alert", comment: "alert title"), message: message, preferredStyle: .alert)
    }
}