//
//  Message+Var+Extension.swift
//  ProtonMail - Created on 11/6/18.
//
//
//  Copyright (c) 2019 Proton Technologies AG
//
//  This file is part of ProtonMail.
//
//  ProtonMail is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  ProtonMail is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with ProtonMail.  If not, see <https://www.gnu.org/licenses/>.


import Foundation
import ProtonCore_DataModel
import ProtonCore_Networking

extension Message {
    
    /// wrappers
    var cachedPassphrase: String? {
        get {
            guard let raw = self.cachedPassphraseRaw as Data? else { return nil }
            return String(data: raw, encoding: .utf8)
        }
        set { self.cachedPassphraseRaw = newValue?.data(using: .utf8) as NSData? }
    }
    
    var cachedAuthCredential: AuthCredential? {
        get { return AuthCredential.unarchive(data: self.cachedAuthCredentialRaw) }
        set { self.cachedAuthCredentialRaw = newValue?.archive() as NSData? }
    }
    var cachedUser: UserInfo? {
        get { return UserInfo.unarchive(self.cachedPrivateKeysRaw as Data?) }
        set { self.cachedPrivateKeysRaw = newValue?.archive() as NSData? }
    }
    var cachedAddress: Address? {
        get { return Address.unarchive(self.cachedAddressRaw as Data?) }
        set { self.cachedAddressRaw = newValue?.archive() as NSData? }
    }
    
    /// check if contains exclusive lable
    ///
    /// - Parameter label: Location
    /// - Returns: yes or no
    internal func contains(label: Location) -> Bool {
        return self.contains(label: label.rawValue)
    }
    
    /// check if contains the lable
    ///
    /// - Parameter labelID: label id
    /// - Returns: yes or no
    internal func contains(label labelID : String) -> Bool {
        let labels = self.labels
        for l in labels {
            if let label = l as? Label, labelID == label.labelID {
                return true
            }
        }
        return false
    }
    
    /// check if message starred
    var starred : Bool {
        get {
            return self.contains(label: Location.starred)
        }
    }
    
    /// check if message forwarded
    var forwarded : Bool {
        get {
            return self.flag.contains(.forwarded)
        }
        set {
            var flag = self.flag
            if newValue {
                flag.insert(.forwarded)
            } else {
                flag.remove(.forwarded)
            }
            self.flag = flag
        }
    }
    
    var sentSelf : Bool {
        get {
            return self.flag.contains(.sent) && self.flag.contains(.received)
        }
    }
    
    /// check if message contains a draft label
    var draft : Bool {
        contains(label: Location.draft) || contains(label: HiddenLocation.draft.rawValue)
    }

    var isSent : Bool {
        contains(label: Location.sent) || contains(label: HiddenLocation.sent.rawValue)
    }
    /// get messsage label ids
    ///
    /// - Returns: array
    func getLabelIDs() -> [String] {
        var labelIDs = [String]()
        let labels = self.labels
        for l in labels {
            if let label = l as? Label {
                labelIDs.append(label.labelID)
            }
        }
        return labelIDs
    }
    
    func getNormalLabelIDs() -> [String] {
        var labelIDs = [String]()
        let labels = self.labels
        for l in labels {
            if let label = l as? Label, label.type == 1 {
                if label.labelID.preg_match ("(?!^\\d+$)^.+$") {
                    labelIDs.append(label.labelID )
                }
            }
        }
        return labelIDs
    }
    
    /// check if message replied
    var replied : Bool {
        get {
            return self.flag.contains(.replied)
        }
        set {
            var flag = self.flag
            if newValue {
                flag.insert(.replied)
            } else {
                flag.remove(.replied)
            }
            self.flag = flag
        }
    }
    
    /// check if message replied to all
    var repliedAll : Bool {
        get {
            return self.flag.contains(.repliedAll)
        }
        set {
            var flag = self.flag
            if newValue {
                flag.insert(.repliedAll)
            } else {
                flag.remove(.repliedAll)
            }
            self.flag = flag
        }
    }
    
    /// this will check two type of sent folder
    var sentHardCheck : Bool {
        get {
            return self.contains(label: Message.Location.sent) || self.contains(label: "2")
        }
    }
    
    /// this will check two type of draft folder
    var draftHardCheck : Bool {
        get {
            return self.contains(label: Message.Location.draft) || self.contains(label: "1")
        }
    }

    var hasReceiptRequest: Bool {
        guard let headerString = self.header,
              let data = headerString.data(using: .utf8),
              let parsed = Part(header: data),
              let _ = parsed.headers.first(where: { $0.name == "Disposition-Notification-To"}) else {
            return false
        }
        return true
    }

    var hasSentReceipt: Bool {
        return self.flag.contains(.receiptSent)
    }

    var isAutoReply: Bool {
        guard !isSent, !draft else {
            return false
        }
        let autoReplyKeys = ["X-Autoreply", "X-Autorespond", "X-Autoreply-From", "X-Mail-Autoreply"]
        guard let headersString = header,
              let headerData = headersString.data(using: .utf8),
              let parsedHeader = Part(header: headerData),
              parsedHeader.headers.contains(where: { autoReplyKeys.contains($0.name) }) else {
            return false
        }
        return true
    }

    var isNewsLetter: Bool {
        let helper = NewsLetterCheckHelper()
        return helper.calculateIsNewsLetter(messageHeaderString: self.header ?? "")
    }
}
