//
//  DocumentAttachmentProvider.swift
//  ProtonMail
//
//  Created by Anatoly Rosencrantz on 28/06/2018.
//  Copyright © 2018 ProtonMail. All rights reserved.
//

import Foundation

class DocumentAttachmentProvider: NSObject, AttachmentProvider {
    internal weak var controller: AttachmentController!
    
    init(for controller: AttachmentController) {
        self.controller = controller
    }
    
    var alertAction: UIAlertAction {
        return UIAlertAction(title: LocalString._import_file_from_, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            let types = [
                kUTTypeMovie as String,
                kUTTypeImage as String,
                kUTTypeText as String,
                kUTTypePDF as String,
                kUTTypeGNUZipArchive as String,
                kUTTypeBzip2Archive as String,
                kUTTypeZipArchive as String,
                kUTTypeData as String
            ]
            
            if #available(iOS 11.0, *) {
                // UIDocumentMenuViewController  will be deprecated in iOS 12 and since iOS 11 contains only one `Browse...` option which opens UIDocumentPickerViewController. We can avoid useless middle step.
                let picker = PMDocumentPickerViewController(documentTypes: types, in: .import)
                picker.delegate = self
                picker.allowsMultipleSelection = true
                self.controller.present(picker, animated: true, completion: nil)
            } else {
                // iOS 9 and 10 also allow access to document providers from UIDocumentPickerViewController, but let's keep Menu as it's still useful (until iOS 11)
                let importMenu = UIDocumentMenuViewController(documentTypes: types, in: .import)
                importMenu.delegate = self
                self.controller.present(importMenu, animated: true, completion: nil)
            }
        })
    }
}


@available(iOS, deprecated: 11.0, message: "We don't use UIDocumentMenuViewController for iOS 11+, only UIDocumentPickerViewController")
extension DocumentAttachmentProvider: UIDocumentMenuDelegate {
    func documentMenu(_ documentMenu: UIDocumentMenuViewController, didPickDocumentPicker documentPicker: UIDocumentPickerViewController) {
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.formSheet
        self.controller.present(documentPicker, animated: true, completion: nil)
    }
}

/// Documents
extension DocumentAttachmentProvider: UIDocumentPickerDelegate {
    @available(iOS 11.0, *)
    internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        urls.forEach { self.documentPicker(controller, didPickDocumentAt: $0) }
    }
    
    internal func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        let coordinator : NSFileCoordinator = NSFileCoordinator(filePresenter: nil)
        var error : NSError?
        
        coordinator.coordinate(readingItemAt: url, options: [], error: &error) { new_url in
            guard let data = try? Data(contentsOf: url) else {
                self.controller.error(LocalString._cant_load_the_file)
                return
            }
            self.controller.finish(data, filename: url.lastPathComponent, extension: url.mimeType())
        }
        
        if error != nil {
            self.controller.error(LocalString._cant_copy_the_file)
        }
    }
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        PMLog.D("")
    }
    
}
