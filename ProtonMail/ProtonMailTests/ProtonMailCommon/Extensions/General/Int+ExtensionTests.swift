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

import XCTest
@testable import ProtonMail

final class Int_ExtensionTests: XCTestCase {
    /*
     Source of ByteCountFormatter
     https://github.com/apple/swift-corelibs-foundation/blob/a61b058ed53b00621e7acba4c53959e3ae01a254/Foundation/ByteCountFormatter.swift
     */
    func testToByteCount() {
        XCTAssertEqual(8.toByteCount, "8 bytes")
        XCTAssertEqual(1024.toByteCount, "1 KB")
        // The default countStyle is `file`, 1000 bytes is 1 KB
        XCTAssertEqual(1000.toByteCount, "1 KB")
        XCTAssertEqual((1024 * 1024).toByteCount, "1 MB")
        // The accuracy is different in GB level
        XCTAssertEqual((1024 * 1024 * 1024).toByteCount, "1.07 GB")
    }
}
