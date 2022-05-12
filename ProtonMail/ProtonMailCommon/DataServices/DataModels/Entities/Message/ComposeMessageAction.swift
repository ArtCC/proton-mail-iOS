// Copyright (c) 2022 Proton Technologies AG
//
// This file is part of ProtonMail.
//
// ProtonMail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// ProtonMail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with ProtonMail. If not, see https://www.gnu.org/licenses/.

import Foundation

enum ComposeMessageAction: Int, CustomStringConvertible {
    case reply = 0
    case replyAll = 1
    case forward = 2
    case newDraft = 3
    case openDraft = 4
    case newDraftFromShare = 5

    /// localized description
    public var description: String {
        switch self {
        case .reply:
            return LocalString._general_reply_button
        case .replyAll:
            return LocalString._general_replyall_button
        case .forward:
            return LocalString._general_forward_button
        case .newDraft, .newDraftFromShare:
            return LocalString._general_draft_action
        case .openDraft:
            return ""
        }
    }
}