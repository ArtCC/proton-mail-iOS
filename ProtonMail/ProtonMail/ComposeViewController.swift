//
// Copyright 2015 ArcTouch, Inc.
// All rights reserved.
//
// This file, its contents, concepts, methods, behavior, and operation
// (collectively the "Software") are protected by trade secret, patent,
// and copyright laws. The use of the Software is governed by a license
// agreement. Disclosure of the Software to third parties, in any form,
// in whole or in part, is expressly prohibited except as authorized by
// the license agreement.
//

import UIKit

class ComposeViewController: ProtonMailViewController {

    private struct EncryptionStep {
        static let DefinePassword = "DefinePassword"
        static let ConfirmPassword = "ConfirmPassword"
        static let DefineHintPassword = "DefineHintPassword"
    }
    
    // MARK: - Private attributes
    
    var attachments: [AnyObject]?
    var message: Message?
    var action: String!
    
    var toSelectedContacts: [ContactVO]! = [ContactVO]()
    private var ccSelectedContacts: [ContactVO]! = [ContactVO]()
    private var bccSelectedContacts: [ContactVO]! = [ContactVO]()
    private var contacts: [ContactVO]! = [ContactVO]()
    private var composeView: ComposeView!
    private var actualEncryptionStep = EncryptionStep.DefinePassword
    private var encryptionPassword: String = ""
    private var encryptionConfirmPassword: String = ""
    private var encryptionPasswordHint: String = ""
    private var hasAccessToAddressBook: Bool = false

    
    // MARK: - View Controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.composeView = self.view as? ComposeView
        self.composeView.datasource = self
        self.composeView.delegate = self
        
        if let message = message {
            if (action == ComposeView.ComposeMessageAction.Reply) {
                composeView.subject.text = "Re: \(message.title)"
                toSelectedContacts.append(ContactVO(id: "", name: message.senderName, email: message.sender))
            }

            if (action == ComposeView.ComposeMessageAction.ReplyAll) {
                composeView.subject.text = "Re: \(message.title)"
                
                toSelectedContacts.append(ContactVO(id: "", name: message.senderName, email: message.sender))
                
                let ccNames = split(message.ccNameList) {$0 == ","}
                let ccEmails = split(message.ccList) {$0 == ","}
                
                for (var i = 0; i < countElements(ccEmails); i++) {
                    ccSelectedContacts.append(ContactVO(id: "", name: ccNames[i], email: ccEmails[i]))
                }
            }
            
            if (action == ComposeView.ComposeMessageAction.Forward) {
                composeView.subject.text = "Fwd: \(message.title)"
                composeView.bodyTextView.text = message.decryptBody(nil)
            }
        }
        
        retrieveAddressBook()
        retrieveServerContactList { () -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.contacts.sort { $0.name.lowercaseString < $1.name.lowercaseString }
                self.composeView.toContactPicker.reloadData()
                self.composeView.ccContactPicker.reloadData()
                self.composeView.bccContactPicker.reloadData()
                self.composeView.finishRetrievingContacts()
            })
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.composeView.updateConstraintsIfNeeded()
        
        if (toSelectedContacts.count == 0) {
            self.composeView.toContactPicker.becomeFirstResponder()
        } else {
            self.composeView.bodyTextView.becomeFirstResponder()
        }
    }
    
    
    // MARK: ProtonMail View Controller
    
    override func shouldShowSideMenu() -> Bool {
        return false
    }
}


// MARK: - AttachmentsViewControllerDelegate
extension ComposeViewController: AttachmentsViewControllerDelegate {
    func attachmentsViewController(attachmentsViewController: AttachmentsViewController, didFinishPickingAttachments attachments: [AnyObject]) {
        self.attachments = attachments
    }
}


// MARK: - ComposeViewDelegate
extension ComposeViewController: ComposeViewDelegate {
    func composeViewDidTapCancelButton(composeView: ComposeView) {
        let dismiss = {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        if composeView.hasContent || ((attachments?.count ?? 0) > 0) {
            let alertController = UIAlertController(title: NSLocalizedString("Confirmation"), message: nil, preferredStyle: .ActionSheet)
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Save draft"), style: .Default, handler: { (action) -> Void in
                sharedMessageDataService.saveDraft(
                    recipientList: composeView.toContacts,
                    bccList: composeView.bccContacts,
                    ccList: composeView.ccContacts,
                    title: composeView.subjectTitle,
                    encryptionPassword: self.encryptionPassword,
                    passwordHint: self.encryptionPasswordHint,
                    expirationTimeInterval: composeView.expirationTimeInterval,
                    body: composeView.body,
                    attachments: self.attachments)
                
                dismiss()
            }))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel"), style: .Cancel, handler: nil))
            alertController.addAction(UIAlertAction(title: NSLocalizedString("Discard draft"), style: .Destructive, handler: { (action) -> Void in
                dismiss()
            }))
            
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            dismiss()
        }
    }
    
    func composeViewDidTapSendButton(composeView: ComposeView) {
        sharedMessageDataService.send(
            recipientList: composeView.toContacts,
            bccList: composeView.bccContacts,
            ccList: composeView.ccContacts,
            title: composeView.subjectTitle,
            encryptionPassword: encryptionPassword,
            passwordHint: encryptionPasswordHint,
            expirationTimeInterval: composeView.expirationTimeInterval,
            body: composeView.body,
            attachments: attachments)
        
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }

    func composeViewDidTapEncryptedButton(composeView: ComposeView) {
        self.actualEncryptionStep = EncryptionStep.DefinePassword
        self.composeView.showDefinePasswordView()
        self.composeView.hidePasswordAndConfirmDoesntMatch()
    }
    
    func composeViewDidTapNextButton(composeView: ComposeView) {
        switch(actualEncryptionStep) {
        case EncryptionStep.DefinePassword:
            self.encryptionPassword = composeView.encryptedPasswordTextField.text ?? ""
            self.actualEncryptionStep = EncryptionStep.ConfirmPassword
            self.composeView.showConfirmPasswordView()
            
        case EncryptionStep.ConfirmPassword:
            self.encryptionConfirmPassword = composeView.encryptedPasswordTextField.text ?? ""
            
            if (self.encryptionPassword == self.encryptionConfirmPassword) {
                self.actualEncryptionStep = EncryptionStep.DefineHintPassword
                self.composeView.hidePasswordAndConfirmDoesntMatch()
                self.composeView.showPasswordHintView()
            } else {
                self.composeView.showPasswordAndConfirmDoesntMatch()
            }
            
        case EncryptionStep.DefineHintPassword:
            self.encryptionPasswordHint = composeView.encryptedPasswordTextField.text ?? ""
            self.actualEncryptionStep = EncryptionStep.DefinePassword
            self.composeView.showEncryptionDone()
        default:
            println("No step defined.")
        }
    }
    
    func composeView(composeView: ComposeView, didAddContact contact: ContactVO, toPicker picker: MBContactPicker) {
        var selectedContacts: [ContactVO] = [ContactVO]()
        
        if (picker == composeView.toContactPicker) {
            selectedContacts = toSelectedContacts
        } else if (picker == composeView.ccContactPicker) {
            selectedContacts = ccSelectedContacts
        } else if (picker == composeView.bccContactPicker) {
            selectedContacts = bccSelectedContacts
        }

        selectedContacts.append(contact)
    }
    
    func composeView(composeView: ComposeView, didRemoveContact contact: ContactVO, fromPicker picker: MBContactPicker) {

        var contactIndex = -1
        
        var selectedContacts: [ContactVO] = [ContactVO]()
        
        if (picker == composeView.toContactPicker) {
            selectedContacts = toSelectedContacts
        } else if (picker == composeView.ccContactPicker) {
            selectedContacts = ccSelectedContacts
        } else if (picker == composeView.bccContactPicker) {
            selectedContacts = bccSelectedContacts
        }
        
        for (index, selectedContact) in enumerate(selectedContacts) {
            if (contact.email == selectedContact.email) {
                contactIndex = index
            }
        }
        
        if (contactIndex >= 0) {
            selectedContacts.removeAtIndex(contactIndex)
        }
    }
    
    func composeViewDidTapAttachmentButton(composeView: ComposeView) {
        if let viewController = UIStoryboard.instantiateInitialViewController(storyboard: .attachments) as? UINavigationController {
            if let attachmentsViewController = viewController.viewControllers.first as? AttachmentsViewController {
                attachmentsViewController.delegate = self
                
                if let attachments = attachments {
                    attachmentsViewController.attachments = attachments
                }
            }
            
            presentViewController(viewController, animated: true, completion: nil)
        }
    }
}

// MARK: - ComposeViewDataSource
extension ComposeViewController: ComposeViewDataSource {
    func composeViewContactsModelForPicker(composeView: ComposeView, picker: MBContactPicker) -> [AnyObject]! {
        return contacts
    }
    
    func composeViewSelectedContactsForPicker(composeView: ComposeView, picker: MBContactPicker) ->  [AnyObject]! {
        
        var selectedContacts: [ContactVO] = [ContactVO]()
        
        if (picker == composeView.toContactPicker) {
            selectedContacts = toSelectedContacts
        } else if (picker == composeView.ccContactPicker) {
            selectedContacts = ccSelectedContacts
        } else if (picker == composeView.bccContactPicker) {
            selectedContacts = bccSelectedContacts
        }
        
        return selectedContacts
    }
}


// MARK: - Address book
extension ComposeViewController {
    private func retrieveAddressBook() {
        
        if (sharedAddressBookService.hasAccessToAddressBook()) {
            self.hasAccessToAddressBook = true
        } else {
            sharedAddressBookService.requestAuthorizationWithCompletion({ (granted: Bool, error: NSError?) -> Void in
                if (granted) {
                    self.hasAccessToAddressBook = true
                }
                
                if let error = error {
                    let alertController = error.alertController()
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK"), style: .Default, handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    println("Error trying to access Address Book = \(error.localizedDescription).")
                }
            })
        }
        
        if (self.hasAccessToAddressBook) {
            let addressBookContacts = sharedAddressBookService.contacts()
            for contact: RHPerson in addressBookContacts as [RHPerson] {
                var name: String? = contact.name
                let emails: RHMultiStringValue = contact.emails
                
                for (var emailIndex: UInt = 0; Int(emailIndex) < Int(emails.count()); emailIndex++) {
                    let emailAsString = emails.valueAtIndex(emailIndex) as String
                    
                    if (emailAsString.isValidEmail()) {
                        let email = emailAsString
                        
                        if (name == nil) {
                            name = email
                        }
                        
                        self.contacts.append(ContactVO(name: name, email: email, isProtonMailContact: false))
                    }
                }
            }
        }
    }
    
    private func retrieveServerContactList(completion: () -> Void) {
        sharedContactDataService.fetchContacts { (contacts: [Contact]?, error: NSError?) -> Void in
            if error != nil {
                NSLog("\(error)")
                return
            }
            
            if let contacts = contacts {
                for contact in contacts {
                    self.contacts.append(ContactVO(id: contact.contactID, name: contact.name, email: contact.email, isProtonMailContact: true))
                }
            }
            
            completion()
        }
    }
}