//
//  signinTests.swift
//  ProtonMail - Created on 7/4/19.
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

class LoginTests: BaseTestCase {
    
    private let loginRobot = LoginRobot()

    func testLoginWithOnePass() {
        let user = testData.onePassUser
        loginRobot
            .loginUser(user.email, user.password)
            .verify.loginSuccessful()
    }

    func testLoginWithTwoPass() {
        let user = testData.twoPassUser
        loginRobot
            .loginTwoPasswordUser(user: user)
            .decryptMailbox(user.mailboxPassword)
            .verify.loginSuccessful()
    }
    
    func testLoginWithOnePassAnd2FA() {
        let user = testData.onePassUserWith2Fa
        loginRobot
            .loginUserWithTwoFA(user: user)
            .verify.loginSuccessful()
    }
    
    func testLoginWithTwoPassAnd2FA() {
        let user = testData.twoPassUserWith2Fa
        loginRobot
            .loginTwoPasswordUserWithTwoFA(user: user)
            .decryptMailbox(user.mailboxPassword)
            .verify.loginSuccessful()
    }
}