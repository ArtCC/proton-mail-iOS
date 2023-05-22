// Copyright (c) 2023 Proton Technologies AG
//
// This file is part of Proton Mail.
//
// Proton Mail is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Proton Mail is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Proton Mail. If not, see https://www.gnu.org/licenses/.

import Foundation

protocol DownloadedMessagesViewModelProtocol {
    var input: DownloadedMessagesViewModelInput { get }
    var output: DownloadedMessagesViewModelOutput { get }
}

protocol DownloadedMessagesViewModelInput {
    func viewWillAppear()
    func didChangeStorageLimitValue(newValue: ByteCount)
    func didTapClearStorageUsed()
}

protocol DownloadedMessagesViewModelOutput {
    var sections: [DownloadedMessagesSection] { get }
    var storageLimitSelected: ByteCount { get }
    var localStorageUsed: ByteCount { get }
    var searchIndexState: EncryptedSearchIndexState { get }
    var oldestMessageTime: String { get }

    func setUIDelegate(_ delegate: DownloadedMessagesUIProtocol)
}

protocol DownloadedMessagesUIProtocol: AnyObject {
    func reloadData()
}

enum DownloadedMessagesSection {
    case messageHistory
    case storageLimit
    case localStorageUsed
}
