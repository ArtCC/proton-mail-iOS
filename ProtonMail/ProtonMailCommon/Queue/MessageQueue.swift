//
//  MessageQueue.swift
//  ProtonMail
//
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

import Foundation

let sharedMessageQueue = MessageQueue(queueName: "writeQueue")
let sharedFailedQueue = MessageQueue(queueName: "failedQueue")

class MessageQueue: PersistentQueue {
    fileprivate struct Key {
        static let id = "id"
        static let action = "action"
        static let time = "time"
        static let count = "count"
    }
    
    // MARK: - variables
    var isBlocked: Bool = false
    var isInProgress: Bool = false
    var isRequiredHumanCheck : Bool = false
    
    //TODO::here need input the time of action when local cache changed.
    func addMessage(_ messageID: String, action: MessageAction) -> UUID {
        let time = Date().timeIntervalSince1970
        let element = [Key.id : messageID, Key.action : action.rawValue, Key.time : "\(time)", Key.count : "0"]
        return add(element as NSCoding)
    }
    
    func nextMessage() -> (uuid: UUID, messageID: String, action: String)? {
        if isBlocked || isInProgress || isRequiredHumanCheck {
            return nil
        }
        if let (uuid, object) = next() {
            if let element = object as? [String : String] {
                if let id = element[Key.id] {
                    if let action = element[Key.action] {
                        return (uuid as UUID, id, action)
                    }
                }
            }
            PMLog.D(" Removing invalid networkElement: \(object) from the queue.")
            let _ = remove(uuid)
        }
        return nil
    }
}