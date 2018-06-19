//
//  ComposerViewController.swift
//  ProtonMail
//
//  Created by Yanfeng Zhang on 7/13/17.
//  Copyright © 2017 ProtonMail. All rights reserved.
//

import UIKit
import ZSSRichTextEditor

class ComposerViewController: ZSSRichTextEditor, ViewModelProtocolNew {
    typealias argType = ComposeViewModel
    // view model
    fileprivate var viewModel : ComposeViewModel!
    
    func set(viewModel: ComposeViewModel) {
         self.viewModel = viewModel
    }
    
    func inactiveViewModel() {
    }
    
    // private views
    fileprivate var webView : UIWebView!
    fileprivate var composeView : ComposeView!
    fileprivate var cancelButton: UIBarButtonItem!
    fileprivate var sendButton: UIBarButtonItem!
    
    // private vars
    fileprivate var timer : Timer!
    fileprivate var draggin : Bool! = false
    fileprivate var contacts: [ContactVO]! = [ContactVO]()
    fileprivate var actualEncryptionStep = EncryptionStep.DefinePassword
    fileprivate var encryptionPassword: String = ""
    fileprivate var encryptionConfirmPassword: String = ""
    fileprivate var encryptionPasswordHint: String = ""
    fileprivate var hasAccessToAddressBook: Bool = false
    //
    fileprivate var attachments: [Any]?
    
    @IBOutlet weak var expirationPicker: UIPickerView!
    // offsets
    fileprivate var composeViewSize : CGFloat = 186;
    
    // MARK : const values
    fileprivate let kNumberOfColumnsInTimePicker: Int = 2
    fileprivate let kNumberOfDaysInTimePicker: Int = 30
    fileprivate let kNumberOfHoursInTimePicker: Int = 24
    
    fileprivate let kPasswordSegue : String = "to_eo_password_segue"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = []
        
        //inital navigation bar items
        self.cancelButton = UIBarButtonItem(title: LocalString._general_cancel_button,
                                            style: .plain,
                                            target: self,
                                            action: #selector(ComposerViewController.cancelButtonTapped(sender:)))
        self.sendButton = UIBarButtonItem(image: UIImage(named:"sent_compose"),
                                          style: .plain,
                                          target: self,
                                          action: #selector(ComposerViewController.send_clicked(sender:)))
        self.navigationItem.leftBarButtonItem = self.cancelButton
        self.navigationItem.rightBarButtonItem = self.sendButton
        
        self.configureNavigationBar()
        
        //inital webview
        self.baseURL = URL( fileURLWithPath: "https://protonmail.ch")
        //self.formatHTML = false
        self.webView = self.getWebView()
        
        // init views
        self.composeView = ComposeView(nibName: "ComposeView", bundle: nil)
        let w = UIScreen.main.applicationFrame.width;
        self.composeView.view.frame = CGRect(x: 0, y: 0, width: w, height: composeViewSize + 60)
        self.composeView.delegate = self
        self.composeView.datasource = self
        self.webView.scrollView.addSubview(composeView.view);
        self.webView.scrollView.bringSubview(toFront: composeView.view)
        
        // update content values
        updateMessageView()
        //self.contacts = sharedContactDataService.allContactVOs()
        retrieveAllContacts()
        
        self.expirationPicker.alpha = 0.0
        self.expirationPicker.dataSource = self
        self.expirationPicker.delegate = self
        
        self.attachments = viewModel.getAttachments()
        
        // update header layous
        updateContentLayout(false)
        
        //change message as read
        self.viewModel.markAsRead();
        
        
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func send_clicked(sender: UIBarButtonItem) {
        self.dismissKeyboard()
        if let suject = self.composeView.subject.text {
            if !suject.isEmpty {
                self.sendMessage()
                return
            }
        }
        
        let alertController = UIAlertController(title: LocalString._composer_compose_action,
                                                message: LocalString._composer_send_no_subject_desc,
                                                preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: LocalString._general_send_action,
                                                style: .destructive, handler: { (action) -> Void in
            self.sendMessage()
        }))
        alertController.addAction(UIAlertAction(title: LocalString._general_cancel_button, style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func cancelButtonTapped(sender: UIBarButtonItem) {
        self.dismissKeyboard()
        let dismiss: (() -> Void) = {
            self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
                let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSFileNoSuchFileError, userInfo: nil)
                self.extensionContext!.cancelRequest(withError: cancelError)
            })
        }
        
        //if self.viewModel.hasDraft || composeView.hasContent || ((attachments?.count ?? 0) > 0) {
        let alertController = UIAlertController(title: LocalString._general_confirmation_title, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: LocalString._composer_save_draft_action,
                                                style: .default, handler: { (action) -> Void in
            self.stopAutoSave()
            self.collectDraft()
            self.viewModel.updateDraft()
            dismiss()
        }))
        alertController.addAction(UIAlertAction(title: LocalString._general_cancel_button, style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: LocalString._composer_discard_draft_action,
                                                style: .destructive, handler: { (action) -> Void in
            self.stopAutoSave()
            self.viewModel.deleteDraft()
            dismiss()
        }))
        
        alertController.popoverPresentationController?.barButtonItem = sender
        alertController.popoverPresentationController?.sourceRect = self.view.frame
        present(alertController, animated: true, completion: nil)
    }
    
    func hideExtensionWithCompletionHandler(completion:@escaping (Bool) -> Void) {
        UIView.animate(withDuration: 0.50, animations: { () -> Void in
            self.navigationController!.view.transform = CGAffineTransform(translationX: 0, y: self.navigationController!.view.frame.size.height)
        }, completion: completion)
    }
    
    
    internal func updateEmbedImages() {
        if let atts = viewModel.getAttachments() {
            for att in atts {
                if let content_id = att.contentID(), !content_id.isEmpty && att.inline() {
                    att.base64AttachmentData({ (based64String) in
                        if !based64String.isEmpty {
                            self.updateEmbedImage(byCID: "cid:\(content_id)", blob:  "data:\(att.mimeType);base64,\(based64String)");
                        }
                    })
                }
            }
        }
    }
    
    override func webViewDidFinishLoad(_ webView: UIWebView) {
        super.webViewDidFinishLoad(webView)
        updateEmbedImages()
        
        self.composeView.notifyViewSize(true)
    }
    
    override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
        self.composeView.notifyViewSize(true)
    }
    
    fileprivate func dismissKeyboard() {
        self.composeView.subject.becomeFirstResponder()
        self.composeView.subject.resignFirstResponder()
    }
    
    fileprivate func updateMessageView() {
        self.composeView.updateFromValue(self.viewModel.getDefaultSendAddress()?.email ?? "", pickerEnabled: true)
        self.composeView.subject.text = self.viewModel.getSubject();
        self.shouldShowKeyboard = false
        self.setHTML(self.viewModel.getHtmlBody())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updateAttachmentButton()
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(ComposerViewController.willResignActiveNotification(_:)), name: NSNotification.Name.UIApplicationWillResignActive, object:nil)
        setupAutoSave()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object:nil)
        stopAutoSave()
    }
    
    @objc internal func willResignActiveNotification (_ notify: Notification) {
        self.autoSaveTimer()
        dismissKeyboard()
    }
    
    internal func statusBarHit (_ notify: Notification) {
        webView.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            self.updateComposeFrame()
        } else {
            // Fallback on earlier versions
        }
    }
    
    @available(iOS 11.0, *)
    internal func updateComposeFrame() {
        let inset = self.view.safeAreaInsets
        let offset = inset.left + inset.right
        var w = UIScreen.main.applicationFrame.width - offset;
        if w < 0 {
            w = 0
        }
        var frame = self.view.frame
        frame.size.width = w
        self.view.frame = frame
        self.composeView.view.frame = CGRect(x: 0, y: 0, width: w, height: composeViewSize)
    }
    
    // ******************
    func configureNavigationBar() {
        self.navigationController?.navigationBar.barStyle = UIBarStyle.black
        self.navigationController?.navigationBar.barTintColor = UIColor.ProtonMail.Nav_Bar_Background;
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        let navigationBarTitleFont = Fonts.h2.regular
        self.navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedStringKey.foregroundColor: UIColor.white,
            NSAttributedStringKey.font: navigationBarTitleFont
        ]
    }
    
    fileprivate func retrieveAllContacts() {
        sharedContactDataService.getContactVOs { (contacts, error) in
            if let error = error {
                PMLog.D(" error: \(error)")
            }
            
            //TODO::
            self.contacts = contacts
            
            self.composeView.toContactPicker.reloadData()
            self.composeView.ccContactPicker.reloadData()
            self.composeView.bccContactPicker.reloadData()
            
            self.composeView.toContactPicker.contactCollectionView.layoutIfNeeded()
            self.composeView.bccContactPicker.contactCollectionView.layoutIfNeeded()
            self.composeView.ccContactPicker.contactCollectionView.layoutIfNeeded()
            
            switch self.viewModel.messageAction!
            {
            case .openDraft, .reply, .replyAll:
                self.focus()
                self.composeView.notifyViewSize(true)
                break
            default:
                let _ = self.composeView.toContactPicker.becomeFirstResponder()
                break
            }
        }
    }
    
    fileprivate func updateContentLayout(_ animation: Bool) {
        UIView.animate(withDuration: animation ? 0.25 : 0, animations: { () -> Void in
            for subview in self.webView.scrollView.subviews {
                let sub = subview
                if sub == self.composeView.view {
                    continue
                } else if sub is UIImageView {
                    continue
                } else {
                    let h : CGFloat = self.composeViewSize
                    self.updateFooterOffset(h)
                    sub.frame = CGRect(x: sub.frame.origin.x, y: h, width: sub.frame.width, height: sub.frame.height);
                }
            }
        })
    }
    
    // MARK: - Private methods
    fileprivate func setupAutoSave() {
        self.timer = Timer.scheduledTimer(timeInterval: 120, target: self, selector: #selector(ComposerViewController.autoSaveTimer), userInfo: nil, repeats: true)
    }
    
    fileprivate func stopAutoSave() {
        if self.timer != nil {
            self.timer.invalidate()
            self.timer = nil
        }
    }
    
    @objc func autoSaveTimer() {
        self.collectDraft()
        self.viewModel.updateDraft()
    }
    
    fileprivate func collectDraft() {
        let orignal = self.getOrignalEmbedImages()
        let edited = self.getEditedEmbedImages()
        self.checkEmbedImageEdit(orignal!, edited: edited!)
        var body = self.getHTML()
        if (body?.isEmpty)! {
            body = "<div><br></div>"
        }
        self.viewModel.collectDraft(
            self.composeView.subject.text!,
            body: body!,
            expir: self.composeView.expirationTimeInterval,
            pwd:self.encryptionPassword,
            pwdHit:self.encryptionPasswordHint
        )
    }
    
    fileprivate func checkEmbedImageEdit(_ orignal: String, edited: String) {
        PMLog.D(edited)
        if let atts = viewModel.getAttachments() {
            for att in atts {
                if let content_id = att.contentID(), !content_id.isEmpty && att.inline() {
                    PMLog.D(content_id)
                    if orignal.contains(content_id) {
                        if !edited.contains(content_id) {
                            self.viewModel.deleteAtt(att)
                        }
                    }
                }
            }
        }
    }
    
    internal func sendMessage () {
        if self.composeView.expirationTimeInterval > 0 {
            if self.composeView.hasOutSideEmails && self.encryptionPassword.count <= 0 {
                let emails = self.composeView.allEmails
                //show loading
                ActivityIndicatorHelper.showActivityIndicator(at: view)
                let api = GetUserPublicKeysRequest<EmailsCheckResponse>(emails: emails)
                api.call({ (task, response: EmailsCheckResponse?, hasError : Bool) in
                    //hide loading
                    ActivityIndicatorHelper.hideActivityIndicator(at: self.view)
                    if let res = response, res.hasOutsideEmails == false {
                        self.sendMessageStepTwo()
                    } else {
                        self.composeView.showPasswordAndConfirmDoesntMatch(LocalString._composer_eo_pls_set_password)
                    }
                })
                return
            }
        }
        delay(0.3) {
            self.sendMessageStepTwo()
        }
    }
    
    internal func sendMessageStepTwo() {
        if self.viewModel.toSelectedContacts.count <= 0 &&
            self.viewModel.ccSelectedContacts.count <= 0 &&
            self.viewModel.bccSelectedContacts.count <= 0 {
            let alert = UIAlertController(title: LocalString._general_alert_title,
                                          message: LocalString._composer_no_recipient_error,
                                          preferredStyle: .alert)
            alert.addAction((UIAlertAction.okAction()))
            present(alert, animated: true, completion: nil)
            return
        }
        
        stopAutoSave()
        self.collectDraft()
        self.viewModel.sendMessage()
        
        self.hideExtensionWithCompletionHandler(completion: { (Bool) -> Void in
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
    }
    
    fileprivate func updateAttachmentButton () {
        if let att = attachments, att.count > 0 {
            self.composeView.updateAttachmentButton(true)
        } else {
            self.composeView.updateAttachmentButton(false)
        }
    }
}

extension ComposerViewController : PasswordEncryptViewControllerDelegate {
    
    func Cancelled() {
        
    }
    
    func Apply(_ password: String, confirmPassword: String, hint: String) {
        self.encryptionPassword        = password
        self.encryptionConfirmPassword = confirmPassword
        self.encryptionPasswordHint    = hint
        
        self.composeView.showEncryptionDone()
    }
    
    func Removed() {
        self.encryptionPassword        = ""
        self.encryptionConfirmPassword = ""
        self.encryptionPasswordHint    = ""
        
        self.composeView.showEncryptionRemoved()
    }
}


// MARK : - view extensions
extension ComposerViewController : ComposeViewDelegate {
    func lockerCheck(model: ContactPickerModelProtocol, progress: () -> Void, complete: LockCheckComplete?) {
        self.viewModel.lockerCheck(model: model, progress: progress, complete: complete)
    }
    
    func composeViewPickFrom(_ composeView: ComposeView) {
        var needsShow : Bool = false
        let alertController = UIAlertController(title: LocalString._composer_change_sender_address_to, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: LocalString._general_cancel_button, style: .cancel, handler: nil))
        let multi_domains = self.viewModel.getAddresses()
        let defaultAddr = self.viewModel.getDefaultSendAddress()
        for addr in multi_domains {
            if addr.status == 1 && addr.receive == 1 && defaultAddr != addr {
                needsShow = true
                alertController.addAction(UIAlertAction(title: addr.email, style: .default, handler: { (action) -> Void in
                    if addr.send == 0 {
                        let alertController = String(format: LocalString._composer_change_paid_plan_sender_error, addr.email).alertController()
                        alertController.addOKAction()
                        self.present(alertController, animated: true, completion: nil)
                    } else {
                        if let signature = self.viewModel.getCurrrentSignature(addr.address_id) {
                            self.updateSignature("\(signature)")
                        }
                        
                        ActivityIndicatorHelper.showActivityIndicator(at: self.view)
                        self.viewModel.updateAddressID(addr.address_id).done {
                            self.composeView.updateFromValue(addr.email, pickerEnabled: true)
                        }.catch { (error ) in
                            let alertController = error.localizedDescription.alertController()
                            alertController.addOKAction()
                            self.present(alertController, animated: true, completion: nil)
                        }.finally {
                            ActivityIndicatorHelper.hideActivityIndicator(at: self.view)
                        }
                    }
                }))
            }
        }
        if needsShow {
            alertController.popoverPresentationController?.sourceView = self.composeView.fromView
            alertController.popoverPresentationController?.sourceRect = self.composeView.fromView.frame
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func ComposeViewDidSizeChanged(_ size: CGSize, showPicker: Bool) {
        self.composeViewSize = size.height;
        if #available(iOS 11.0, *) {
            self.updateComposeFrame()
        } else {
            let w = UIScreen.main.applicationFrame.width
            self.composeView.view.frame = CGRect(x: 0, y: 0, width: w, height: composeViewSize)
        }
        self.updateContentLayout(true)
        self.webView.scrollView.isScrollEnabled = !showPicker
    }
    
    func ComposeViewDidOffsetChanged(_ offset: CGPoint){
    }
    
    func composeViewDidTapNextButton(_ composeView: ComposeView) {
        
    }
    
    func composeViewDidTapEncryptedButton(_ composeView: ComposeView) {
        let passwordVC = PasswordEncryptViewController(nibName: "PasswordEncryptViewController", bundle: nil)
        
        passwordVC.providesPresentationContextTransitionStyle = true;
        passwordVC.definesPresentationContext                 = true;
        passwordVC.modalTransitionStyle                       = .crossDissolve
        passwordVC.modalPresentationStyle                     = UIModalPresentationStyle.overCurrentContext
        passwordVC.pwdDelegate                                = self
        
        passwordVC.setupPasswords(self.encryptionPassword, confirmPassword: self.encryptionConfirmPassword, hint: self.encryptionPasswordHint)
        self.present(passwordVC, animated: true) {
            //nothing
        }
    }
    
    func composeViewDidTapAttachmentButton(_ composeView: ComposeView) {
        if let viewController = UIStoryboard.instantiateInitialViewController(storyboard: .attachments) as? UINavigationController {
            if let attachmentsViewController = viewController.viewControllers.first as? AttachmentsTableViewController {
                attachmentsViewController.delegate = self
                attachmentsViewController.message = viewModel.message;
                if let _ = attachments {
                    attachmentsViewController.attachments = viewModel.getAttachments() ?? []
                }
            }
            present(viewController, animated: true, completion: nil)
        }
    }
    
    func composeViewDidTapExpirationButton(_ composeView: ComposeView)
    {
        self.expirationPicker.alpha = 1;
        self.view.bringSubview(toFront: expirationPicker)
    }
    
    func composeViewHideExpirationView(_ composeView: ComposeView)
    {
        self.expirationPicker.alpha = 0;
    }
    
    func composeViewCancelExpirationData(_ composeView: ComposeView)
    {
        self.expirationPicker.selectRow(0, inComponent: 0, animated: true)
        self.expirationPicker.selectRow(0, inComponent: 1, animated: true)
    }
    
    func composeViewCollectExpirationData(_ composeView: ComposeView)
    {
        let selectedDay = expirationPicker.selectedRow(inComponent: 0)
        let selectedHour = expirationPicker.selectedRow(inComponent: 1)
        if self.composeView.setExpirationValue(selectedDay, hour: selectedHour)
        {
            self.expirationPicker.alpha = 0;
        }
    }
    
    func composeView(_ composeView: ComposeView, didAddContact contact: ContactVO, toPicker picker: ContactPicker) {
        if (picker == composeView.toContactPicker) {
            self.viewModel.toSelectedContacts.append(contact)
        } else if (picker == composeView.ccContactPicker) {
            self.viewModel.ccSelectedContacts.append(contact)
        } else if (picker == composeView.bccContactPicker) {
            self.viewModel.bccSelectedContacts.append(contact)
        }
    }
    
    func composeView(_ composeView: ComposeView, didRemoveContact contact: ContactVO, fromPicker picker:ContactPicker) {
        // here each logic most same, need refactor later
        if (picker == composeView.toContactPicker) {
            var contactIndex = -1
            let selectedContacts = self.viewModel.toSelectedContacts
            for (index, selectedContact) in (selectedContacts?.enumerated())! {
                if (contact.email == selectedContact.email) {
                    contactIndex = index
                }
            }
            if (contactIndex >= 0) {
                self.viewModel.toSelectedContacts.remove(at: contactIndex)
            }
        } else if (picker == composeView.ccContactPicker) {
            var contactIndex = -1
            let selectedContacts = self.viewModel.ccSelectedContacts
            for (index, selectedContact) in (selectedContacts?.enumerated())! {
                if (contact.email == selectedContact.email) {
                    contactIndex = index
                }
            }
            if (contactIndex >= 0) {
                self.viewModel.ccSelectedContacts.remove(at: contactIndex)
            }
        } else if (picker == composeView.bccContactPicker) {
            var contactIndex = -1
            let selectedContacts = self.viewModel.bccSelectedContacts
            for (index, selectedContact) in (selectedContacts?.enumerated())! {
                if (contact.email == selectedContact.email) {
                    contactIndex = index
                }
            }
            if (contactIndex >= 0) {
                self.viewModel.bccSelectedContacts.remove(at: contactIndex)
            }
        }
    }
}


// MARK : compose data source
extension ComposerViewController : ComposeViewDataSource {

    func composeViewContactsModelForPicker(_ composeView: ComposeView, picker: ContactPicker) -> [ContactPickerModelProtocol] {
        return contacts
    }
    
    func composeViewSelectedContactsForPicker(_ composeView: ComposeView, picker: ContactPicker) ->  [ContactPickerModelProtocol] {
        var selectedContacts: [ContactVO] = [ContactVO]()
        if (picker == composeView.toContactPicker) {
            selectedContacts = self.viewModel.toSelectedContacts
        } else if (picker == composeView.ccContactPicker) {
            selectedContacts = self.viewModel.ccSelectedContacts
        } else if (picker == composeView.bccContactPicker) {
            selectedContacts = self.viewModel.bccSelectedContacts
        }
        return selectedContacts
    }
}

// MARK: - AttachmentsViewControllerDelegate
extension ComposerViewController: AttachmentsTableViewControllerDelegate {
    func attachments(_ attViewController: AttachmentsTableViewController, didFinishPickingAttachments attachments: [Any]) {
        self.attachments = attachments
        self.updateAttachmentButton()
    }
    
    func attachments(_ attViewController: AttachmentsTableViewController, didPickedAttachment attachment: Attachment) {
        self.collectDraft()
        self.viewModel.uploadAtt(attachment)
    }
    
    func attachments(_ attViewController: AttachmentsTableViewController, didDeletedAttachment attachment: Attachment) {
        self.collectDraft()

        if let content_id = attachment.contentID(), !content_id.isEmpty && attachment.inline() {
            self.removeEmbedImage(byCID: "cid:\(content_id)")
        }
        
        self.viewModel.deleteAtt(attachment)
    }
    
    func attachments(_ attViewController: AttachmentsTableViewController, didReachedSizeLimitation: Int) {
        
    }
    
    func attachments(_ attViewController: AttachmentsTableViewController, error: String) {
        
    }
}

// MARK: - UIPickerViewDataSource
extension ComposerViewController : UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return kNumberOfColumnsInTimePicker
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0) {
            return kNumberOfDaysInTimePicker
        } else {
            return kNumberOfHoursInTimePicker
        }
    }
}

// MARK: - UIPickerViewDelegate
extension ComposerViewController : UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (component == 0) {
            return "\(row) " + LocalString._composer_eo_days_title
        } else {
            return "\(row) " + LocalString._composer_eo_hours_title
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedDay = pickerView.selectedRow(inComponent: 0)
        let selectedHour = pickerView.selectedRow(inComponent: 1)
        
        let day = "\(selectedDay) " + LocalString._composer_eo_days_title
        let hour = "\(selectedHour) " + LocalString._composer_eo_hours_title
        self.composeView.updateExpirationValue(((Double(selectedDay) * 24) + Double(selectedHour)) * 3600, text: "\(day) \(hour)")
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return super.canPerformAction(action, withSender: sender)
    }
    
}
