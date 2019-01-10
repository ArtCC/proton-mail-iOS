//
//  AnyStorefrontItem.swift
//  ProtonMail - Created on 18/12/2018.
//
//
//  The MIT License
//
//  Copyright (c) 2018 Proton Technologies AG
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
    

import Foundation

class AnyStorefrontItem: NSObject { }
class LogoStorefrontItem: AnyStorefrontItem {
    typealias ColoredSubtitle = (String, UIColor) // FIXME: NSAttributedString instead of color
    var imageName: String
    var title: String
    var subtitle: ColoredSubtitle
    
    init(imageName: String, title: String, subtitle: ColoredSubtitle) {
        self.imageName = imageName
        self.title = title
        self.subtitle = subtitle
    }
}
class DetailStorefrontItem: AnyStorefrontItem {
    var imageName: String
    var text: String
    
    init(imageName: String, text: String) {
        self.imageName = imageName
        self.text = text
    }
}
class AnnotationStorefrontItem: AnyStorefrontItem {
    var text: NSAttributedString
    init(text: NSAttributedString) {
        self.text = text
    }
}
class SubsectionHeaderStorefrontItem: AnyStorefrontItem {
    var text: String
    init(text: String) {
        self.text = text
    }
}
class DisclaimerStorefrontItem: AnyStorefrontItem {
    var text: String
    init(text: String) {
        self.text = text
    }
}
class LinkStorefrontItem: AnyStorefrontItem {
    var text: NSAttributedString
    init(text: NSAttributedString) {
        self.text = text
    }
}
class BuyButtonStorefrontItem: AnyStorefrontItem {
    var subtitle: String?
    var buttonTitle: NSAttributedString?
    var buttonEnabled: Bool
    
    init(subtitle: String?, buttonTitle: NSAttributedString?, buttonEnabled: Bool) {
        self.subtitle = subtitle
        self.buttonTitle = buttonTitle
        self.buttonEnabled = buttonEnabled
    }
}