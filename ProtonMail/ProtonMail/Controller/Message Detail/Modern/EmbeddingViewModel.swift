//
//  EmbeddingViewModel.swift
//  ProtonMail - Created on 11/04/2019.
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

class EmbeddingViewModel: NSObject {
    private var latestErrorBanner: BannerView?
    
    var numberOfSections: Int {
        fatalError()
    }
    
    func numberOfRows(in section: Int) -> Int {
        fatalError()
    }
}

extension EmbeddingViewModel: BannerRequester {
    internal func errorBannerToPresent() -> BannerView? {
        return self.latestErrorBanner
    }
    
    internal func showErrorBanner(_ title: String, action: @escaping ()->Void) {
        let config = BannerView.ButtonConfiguration(title: LocalString._retry, action: action)
        self.latestErrorBanner = BannerView(appearance: .red, message: title, buttons: config, offset: 8.0)
        UIApplication.shared.sendAction(#selector(BannerPresenting.presentBanner(_:)), to: nil, from: self, for: nil)
    }
}

@objc protocol BannerPresenting {
    @objc func presentBanner(_ sender: BannerRequester)
}
@objc protocol BannerRequester {
    @objc func errorBannerToPresent() -> BannerView?
}
