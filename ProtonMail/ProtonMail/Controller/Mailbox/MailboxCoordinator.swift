//
//  MailboxCoordinator.swift.swift
//  ProtonMail - Created on 12/10/18.
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
import SWRevealViewController

class MailboxCoordinator : DefaultCoordinator {
    typealias VC = MailboxViewController
    
    let viewModel : MailboxViewModel
    var services: ServiceFactory
    
    internal weak var viewController: MailboxViewController?
    internal weak var navigation: UINavigationController?
    internal weak var rvc: SWRevealViewController?
    
    init(vc: MailboxViewController, vm: MailboxViewModel, services: ServiceFactory) {
        self.viewModel = vm
        self.viewController = vc
        self.services = services
    }
    
    init(rvc: SWRevealViewController?, nav: UINavigationController?, vc: MailboxViewController, vm: MailboxViewModel, services: ServiceFactory) {
        self.rvc = rvc
        self.navigation = nav
        self.viewController = vc
        self.viewModel = vm
        self.services = services
    }
    
    weak var delegate: CoordinatorDelegate?
    
    enum Destination : String {
        case composer          = "toCompose"
        case composeShow       = "toComposeShow"
        case search            = "toSearchViewController"
        case details           = "toMessageDetailViewController"
        case detailsFromNotify = "toMessageDetailViewControllerFromNotification"
        case onboarding        = "to_onboarding_segue"
        case feedback          = "to_feedback_segue"
        case feedbackView      = "to_feedback_view_segue"
        case humanCheck        = "toHumanCheckView"
        case folder            = "toMoveToFolderSegue"
        case labels            = "toApplyLabelsSegue"
    }
    
    /// if called from a segue prepare don't call push again
    func start() {
        self.viewController?.set(viewModel: self.viewModel)
        self.viewController?.set(coordinator: self)
        
        if self.navigation != nil, self.rvc != nil {
            self.rvc?.pushFrontViewController(self.navigation, animated: true)
        }
    }
    
    func navigate(from source: UIViewController, to destination: UIViewController, with identifier: String?, and sender: AnyObject?) -> Bool {
        guard let segueID = identifier, let dest = Destination(rawValue: segueID) else {
            return false //
        }
        
        switch dest {
        case .details:
            self.viewController?.cancelButtonTapped()
            guard let next = destination as? MessageViewController else {
                return false
            }
            let vmService = services.get() as ViewModelService
            vmService.messageDetails(fromList: next)
            guard let indexPathForSelectedRow = self.viewController?.tableView.indexPathForSelectedRow,
                let message = self.viewModel.item(index: indexPathForSelectedRow) else {
                    //let alert = LocalString._messages_cant_find_message.alertController()
                    //alert.addOKAction()
                    //present(alert, animated: true, completion: nil)
                    return false
            }
            next.message = message
        case .detailsFromNotify:
            guard let next = destination as? MessageViewController else {
                return false
            }
            let vmService = services.get() as ViewModelService
            vmService.messageDetails(fromPush: next)
            guard let message = self.viewModel.notificationMessage else {
                return false
            }
            next.message = message
            self.viewModel.resetNotificationMessage()
            
        case .composer:
            guard let nav = destination as? UINavigationController else {
                return false
            }
            guard let next = nav.firstViewController() as? ComposeViewController else {
                return false
            }
            let vmService = services.get() as ViewModelService
            vmService.newDraft(vmp: next)
            let viewModel = ComposeViewModelImpl(msg: nil, action: .newDraft)
            let coordinator = ComposeCoordinator(vc: next, vm: viewModel, services: services)
            coordinator.start()
        case .composeShow:
            self.viewController?.cancelButtonTapped()
            guard let nav = destination as? UINavigationController else {
                return false
            }
            guard let next = nav.firstViewController() as? ComposeViewController else {
                return false
            }
            let vmService = services.get() as ViewModelService
            vmService.newDraft(vmp: next)
            
            guard let message = sender as? Message else {
                return false
            }
            let viewModel = ComposeViewModelImpl(msg: message, action: .openDraft)
            let coordinator = ComposeCoordinator(vc: next, vm: viewModel, services: services)
            coordinator.start()
        case .search, .onboarding:
            return true
        case .feedback:
            return false
            //            let popup = segue.destination as! FeedbackPopViewController
            //            popup.feedbackDelegate = self
            //            //popup.viewModel = LabelViewModelImpl(msg: self.getSelectedMessages())
        //            self.setPresentationStyleForSelfController(self, presentingController: popup)
        case .feedbackView:
            return false
        case .humanCheck:
            guard let next = destination as? MailboxCaptchaViewController else {
                return false
            }
            next.viewModel = CaptchaViewModelImpl()
            next.delegate = self.viewController
        case .folder:
            self.viewController?.cancelButtonTapped()
            guard let next = destination as? LablesViewController else {
                return false
            }
            
            guard let messages = sender as? [Message] else {
                return false
            }

            next.viewModel = FolderApplyViewModelImpl(msg: messages)
            next.delegate = self.viewController
        case .labels:
            self.viewController?.cancelButtonTapped()
            guard let next = destination as? LablesViewController else {
                return false
            }
            guard let messages = sender as? [Message] else {
                return false
            }
            next.viewModel = LabelApplyViewModelImpl(msg: messages)
            next.delegate = self.viewController
        }
        return true
    }   
    
    func go(to dest: Destination, sender: Any? = nil) {
        self.viewController?.performSegue(withIdentifier: dest.rawValue, sender: sender)
    }
}