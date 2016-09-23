//
//  LoginRegisterViewController.swift
//  textU
//
//  Created by Abhishek Sharma on 21/09/16.
//  Copyright © 2016 Finoit Technologies. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginRegisterViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate,FBSDKLoginButtonDelegate {
    
    
    @IBOutlet weak var fbLoginBTNView: UIView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var signInButton: GIDSignInButton!
    var loginInButton : FBSDKLoginButton =  FBSDKLoginButton()
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var line1View: UIView!
    @IBOutlet weak var loginRegisterSegmentedControl: UISegmentedControl!
    
    @IBOutlet weak var orLBL: UILabel!
    @IBOutlet weak var line2: UIView!
    @IBOutlet weak var holdingView: UIView!
    @IBOutlet weak var dataView: UIView!
    @IBAction func loginRegisterSegmentControlPressed(sender: AnyObject) {
        if loginRegisterSegmentedControl.selectedSegmentIndex==0{
            login()
        }else{
            register()
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startUp()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        self.loginInButton.frame = self.fbLoginBTNView.frame
        self.loginInButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.holdingView.addSubview(loginInButton)
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        
        print("yes")
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("logout")
    }
    
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError?) {
        if error != nil {
            return
        }
        
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                                     accessToken: authentication.accessToken)
        
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            // ...
            if error != nil{
                print(error)
            }
            print(user?.displayName)
            print(user?.email)
            
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
    }
    
    
    
    func login() -> () {
        self.nameTF.hidden = true
        self.dataView.updateConstraints()
        self.holdingView.layoutIfNeeded()
        self.dataView.layoutIfNeeded()
        self.holdingView.updateConstraints()
        
    }
    
    func register() -> () {
        self.nameTF.hidden = false
        self.holdingView.layoutIfNeeded()
        self.dataView.updateConstraints()
        self.dataView.layoutIfNeeded()
        self.holdingView.updateConstraints()
        
    }
    
    
    
    func startUp() -> () {
        
        // profile Image View Animation on startUp
        UIView.animateWithDuration(0.75, delay: 0, options: .CurveEaseOut, animations: {
            self.profileImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2)
        }) { (isFinished) in
            UIView.animateWithDuration(0.75, delay: 0, options: .CurveEaseOut, animations: {
                self.profileImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
                }, completion: nil)
        }
        
//        self.dataView.translatesAutoresizingMaskIntoConstraints = false
        
        self.navigationController?.navigationBar.hidden = true
        
        self.loginRegisterSegmentedControl.selectedSegmentIndex = 1
        
        

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}
