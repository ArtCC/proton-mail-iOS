//
//  ContactDetailsViewModel.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 5/2/17.
//  Copyright © 2017 ProtonMail. All rights reserved.
//

import Foundation


typealias LoadingProgress = () -> Void

class ContactDetailsViewModel {
    
    init() { }
    
    func paidUser() -> Bool {
        if let role = sharedUserDataService.userInfo?.role, role > 0 {
            return true
        }
        return false
    }
    
    func sections() -> [ContactEditSectionType] {
        fatalError("This method must be overridden")
    }
    
    func statusType2() -> Bool {
        fatalError("This method must be overridden")
    }
    
    func statusType3() -> Bool {
        fatalError("This method must be overridden")
    }
    
    func hasEncryptedContacts() -> Bool {
        fatalError("This method must be overridden")
    }
    
    func getDetails(loading : LoadingProgress, complete: @escaping ContactDetailsComplete) {
        fatalError("This method must be overridden")
    }
    
    func getContact() -> Contact {
        fatalError("This method must be overridden")
    }
    
    func getProfile() -> ContactEditProfile {
        fatalError("This method must be overridden")
    }
    
    func getOrigEmails() -> [ContactEditEmail] {
        fatalError("This method must be overridden")
    }
    
    func getOrigCells() -> [ContactEditPhone] {
        fatalError("This method must be overridden")
    }
    
    func getOrigAddresses() -> [ContactEditAddress] {
        fatalError("This method must be overridden")
    }
    
    func getOrigInformations() -> [ContactEditInformation] {
        fatalError("This method must be overridden")
    }
    
    func getOrigFields() -> [ContactEditField] {
        fatalError("This method must be overridden")
    }
    
    func getOrigNotes() -> [ContactEditNote] {
        fatalError("This method must be overridden")
    }
    
    func export() -> String {
        fatalError("This method must be overridden")
    }
    
    func exportName() -> String {
        fatalError("This method must be overridden")
    }
}
