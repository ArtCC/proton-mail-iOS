//
//  LocalConversationUpdater.swift
//  ProtonMail
//
//
//  Copyright (c) 2021 Proton Technologies AG
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

import CoreData
import Foundation

final class LocalConversationUpdater {
    let userID: String

    init(userID: String) {
        self.userID = userID
    }

    func delete(conversationIDs: [String],
                in context: NSManagedObjectContext,
                completion: ((Result<Void, Error>) -> Void)?) {
        context.performAndWait {
            for conversationID in conversationIDs {
                guard let conversationInContext = Conversation
                        .conversationForConversationID(conversationID,
                                                       inManagedObjectContext: context) else {
                    continue
                }
                // Mark as unread when deleting which will in turn update counters
                mark(conversationIDs: [conversationID],
                     in: context,
                     asUnread: false,
                     labelID: Message.Location.trash.rawValue) { _ in
                    context.delete(conversationInContext)
                    let messages = Message.messagesForConversationID(conversationID,
                                                                     inManagedObjectContext: context)
                    messages?.forEach({ message in
                        context.delete(message)
                    })
                }
            }

            save(context: context, completion: completion)
        }
    }

    func mark(conversationIDs: [String],
              in context: NSManagedObjectContext,
              asUnread: Bool,
              labelID: String,
              completion: ((Result<Void, Error>) -> Void)?) {
        let labelID = labelID
        context.performAndWait {
            for conversationID in conversationIDs {
                guard let conversationInContext = Conversation
                        .conversationForConversationID(conversationID,
                                                       inManagedObjectContext: context) else {
                    continue
                }
                conversationInContext.applyMarksAsChanges(unRead: asUnread, labelID: labelID, context: context)
            }

            save(context: context, completion: completion)
        }
    }

    func editLabels(conversationIDs: [String],
                    in context: NSManagedObjectContext,
                    labelToRemove: String?,
                    labelToAdd: String?,
                    isFolder: Bool,
                    completion: ((Result<Void, Error>) -> Void)?) {
        context.performAndWait {
            for conversationID in conversationIDs {
                guard let conversation = Conversation.conversationForConversationID(conversationID, inManagedObjectContext: context) else {
                    continue
                }
                let messages = Message
                    .messagesForConversationID(conversationID,
                                               inManagedObjectContext: context)
                let untouchedLocations: [Message.Location] = [.draft, .sent, .starred, .archive, .allmail]

                if isFolder {
                    // If folder, first remove all labels that are not draft, sent, starred, archive, allmail
                    let allLabels = conversation.labels as? Set<ContextLabel> ?? []
                    let filteredLabels = allLabels.filter({ !untouchedLocations.map(\.rawValue).contains($0.labelID) })
                    for filteredLabel in filteredLabels {
                        let label = Label.labelForLabelID(filteredLabel.labelID, inManagedObjectContext: context)
                        // We clear only folder type labels
                        if label?.type == 0 || label?.type == 3 {
                            conversation.applyLabelChanges(labelID: filteredLabel.labelID,
                                                           apply: false,
                                                           context: context)
                            messages?.forEach { $0.remove(labelID: filteredLabel.labelID) }
                            let hasUnread = messages?.contains(where: { $0.unRead }) == true ||
                                conversation.isUnread(labelID: filteredLabel.labelID)
                            if hasUnread {
                                updateConversationCount(for: filteredLabel.labelID, offset: -1, in: context)
                            }
                        }
                     }
                }

                if let removed = labelToRemove,
                   !removed.isEmpty,
                   !untouchedLocations.map(\.rawValue).contains(removed) {
                    conversation.applyLabelChanges(labelID: removed, apply: false, context: context)
                    messages?.forEach { $0.remove(labelID: removed) }
                    let hasUnread = messages?.contains(where: { $0.unRead }) == true ||
                        conversation.isUnread(labelID: removed)
                    if hasUnread {
                        updateConversationCount(for: removed, offset: -1, in: context)
                    }
                }

                if let added = labelToAdd, !added.isEmpty {
                    conversation.applyLabelChanges(labelID: added, apply: true, context: context)
                    messages?.forEach { $0.add(labelID: added) }
                    let hasUnread = messages?.contains(where: { $0.unRead }) == true ||
                        conversation.isUnread(labelID: added)
                    if hasUnread {
                        updateConversationCount(for: added, offset: 1, in: context)
                    }
                }
            }
            save(context: context, completion: completion)
        }
    }

    private func updateConversationCount(for labelID: String, offset: Int, in context: NSManagedObjectContext) {
        guard let contextLabel = ConversationCount.lastContextUpdate(by: labelID,
                                                                     userID: self.userID,
                                                                     inManagedObjectContext: context) else {
            return
        }
        contextLabel.unread += Int32(offset)
        contextLabel.unread = max(contextLabel.unread, 0)
    }

    private func save(context: NSManagedObjectContext,
                      completion: ((Result<Void, Error>) -> Void)?) {
        let error = context.saveUpstreamIfNeeded()
        if let error = error {
            PMLog.D(" error: \(error)")
            completion?(.failure(error))
        } else {
            completion?(.success(()))
        }
    }
}