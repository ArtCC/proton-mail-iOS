//
//  SignInViewController.swift
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

import UIKit

class SignInViewController: UIViewController {
    private let animationDuration: NSTimeInterval = 0.5
    private let keyboardPadding: CGFloat = 12
    private let buttonDisabledAlpha: CGFloat = 0.5
    private let mailboxSegue = "mailboxSegue"
    private let signUpKeySegue = "signUpKeySegue"
    private let signUpURL = NSURL(string: "https://protonmail.ch/sign_up.php")!
    
    private var isComeBackFromMailbox = false
    
    var isRemembered = false
        
    @IBOutlet weak var keyboardPaddingConstraint: NSLayoutConstraint!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var rememberButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var rememberView: UIView!
    @IBOutlet weak var signInLabel: UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameTextField.roundCorners()
        passwordTextField.roundCorners()
        rememberButton.selected = isRemembered
        setupSignInButton()
        setupSignUpButton()
        signInIfRememberedCredentials()
        
        if(isRemembered)
        {
            HideLoginViews();
        }
        else
        {
            ShowLoginViews();
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if (!(parent?.isEqual(self.parentViewController) ?? false)) {
            self.isComeBackFromMailbox = true;
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        NSNotificationCenter.defaultCenter().addKeyboardObserver(self)
        
        updateSignInButton(usernameText: usernameTextField.text, passwordText: passwordTextField.text)
        
        
        if(self.isComeBackFromMailbox)
        {
            ShowLoginViews();
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if(UIDevice.currentDevice().isLargeScreen() && !isRemembered)
        {
            usernameTextField.becomeFirstResponder()
        }
    }

    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        NSNotificationCenter.defaultCenter().removeKeyboardObserver(self)
    }
    
    // MARK: - Private methods
    
    private func HideLoginViews()
    {
        self.passwordTextField.hidden = true
        self.rememberView.hidden = true
        self.signInButton.hidden = true
        self.signUpButton.hidden = true
        self.usernameTextField.hidden = true
        self.signInLabel.hidden = true
    }
    
    private func ShowLoginViews()
    {
        UIView.animateWithDuration(1.0, animations: { () -> Void in
            self.passwordTextField.hidden = false
            self.rememberView.hidden = false
            self.signInButton.hidden = false
            self.signUpButton.hidden = false
            self.usernameTextField.hidden = false
            self.signInLabel.hidden = false
            
            }, completion: { finished in
        })

    }
    
    func dismissKeyboard() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    
    func setupSignInButton() {
        signInButton.roundCorners()
        signInButton.alpha = buttonDisabledAlpha
    }
    
    // FIXME: Work around for http://stackoverflow.com/questions/25925914/attributed-string-with-custom-fonts-in-storyboard-does-not-load-correctly <http://openradar.appspot.com/18425809>
    func setupSignUpButton() {
        let needAnAccount = NSLocalizedString("Need an account? ", comment: "Need an account? ")
        let signUp = NSLocalizedString("Sign Up.", comment: "Sign Up.")
        
        let title = NSMutableAttributedString(string: needAnAccount, attributes: [NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleNone.rawValue])
        let signUpAttributed = NSAttributedString(string: signUp, attributes: [NSUnderlineStyleAttributeName : NSUnderlineStyle.StyleSingle.rawValue])
        
        title.appendAttributedString(signUpAttributed)
        
        title.addAttribute(NSFontAttributeName, value: UIFont.robotoThin(size: 12.5), range: NSMakeRange(0, title.length))
        
        signUpButton.setAttributedTitle(title, forState: .Normal)
    }
    
    func signIn() {
        self.isComeBackFromMailbox = false
        MBProgressHUD.showHUDAddedTo(view, animated: true)
        
        sharedUserDataService.signIn(usernameTextField.text, password: passwordTextField.text, isRemembered: isRemembered) { _, error in
            MBProgressHUD.hideHUDForView(self.view, animated: true)
            
            if let error = error {
                NSLog("\(__FUNCTION__) error: \(error)")
                self.ShowLoginViews();
                let alertController = error.alertController()
                alertController.addOKAction()
                
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                if sharedUserDataService.isMailboxPasswordStored {
                    (UIApplication.sharedApplication().delegate as! AppDelegate).switchTo(storyboard: .inbox, animated: true)
                } else {
                    
                    if sharedUserDataService.userInfo?.userStatus > 1 {
                        self.performSegueWithIdentifier(self.mailboxSegue, sender: self)
                    }
                    else {
                        self.performSegueWithIdentifier(self.signUpKeySegue, sender: self)
                    }
                }
            }
        }
    }
    
    func signInIfRememberedCredentials() {
        if sharedUserDataService.isUserCredentialStored {
            isRemembered = true
            rememberButton.selected = true
            usernameTextField.text = sharedUserDataService.username
            passwordTextField.text = sharedUserDataService.password
            
            signIn()
        }
    }
    
    func updateSignInButton(#usernameText: String, passwordText: String) {
        signInButton.enabled = !usernameText.isEmpty && !passwordText.isEmpty
    
        UIView.animateWithDuration(animationDuration, animations: { () -> Void in
            self.signInButton.alpha = self.signInButton.enabled ? 1.0 : self.buttonDisabledAlpha
        })
    }
    
    // MARK: - Actions
    
    @IBAction func rememberButtonAction(sender: UIButton) {
        isRemembered = !isRemembered
        rememberButton.selected = isRemembered
    }
    
    
    @IBAction func signInAction(sender: UIButton) {
        dismissKeyboard()
        signIn()
    }
    
//    @IBAction func signUpAction(sender: UIButton) {
//        dismissKeyboard()
//        UIApplication.sharedApplication().openURL(signUpURL)
//    }
    
    @IBAction func tapAction(sender: UITapGestureRecognizer) {
        dismissKeyboard()
    }
}

// MARK: - NSNotificationCenterKeyboardObserverProtocol
extension SignInViewController: NSNotificationCenterKeyboardObserverProtocol {
    func keyboardWillHideNotification(notification: NSNotification) {
        let keyboardInfo = notification.keyboardInfo
        
        keyboardPaddingConstraint.constant = 0
        
        UIView.animateWithDuration(keyboardInfo.duration, delay: 0, options: keyboardInfo.animationOption, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
    
    func keyboardWillShowNotification(notification: NSNotification) {
        let keyboardInfo = notification.keyboardInfo
        
        keyboardPaddingConstraint.constant = keyboardInfo.beginFrame.height + keyboardPadding
        
        UIView.animateWithDuration(keyboardInfo.duration, delay: 0, options: keyboardInfo.animationOption, animations: { () -> Void in
            self.view.layoutIfNeeded()
            }, completion: nil)
    }
}

// MARK: - UITextFieldDelegate
extension SignInViewController: UITextFieldDelegate {
    func textFieldShouldClear(textField: UITextField) -> Bool {
        updateSignInButton(usernameText: "", passwordText: "")
        return true
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        let text = textField.text as NSString
        let changedText = text.stringByReplacingCharactersInRange(range, withString: string)
        
        if textField == usernameTextField {
            updateSignInButton(usernameText: changedText, passwordText: passwordTextField.text)
        } else if textField == passwordTextField {
            updateSignInButton(usernameText: usernameTextField.text, passwordText: changedText)
        }
        
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        if !usernameTextField.text.isEmpty && !passwordTextField.text.isEmpty {
            signIn()
        }
        
        return true
    }
}