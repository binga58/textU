//
//  LoginRegisterViewController.swift
//  textU
//
//  Created by Abhishek Sharma on 21/09/16.
//  Copyright © 2016 Finoit Technologies. All rights reserved.
//

import UIKit
import Firebase
//import FBSDKLoginKit\
import FirebaseDatabase
import FirebaseAuth

class LoginRegisterViewController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate,FBSDKLoginButtonDelegate,UITextFieldDelegate {

//    @IBOutlet weak var activityIndicatorView: UIVisualEffectView!
    @IBOutlet weak var insideViewOfBlurView: UIView!
    @IBOutlet weak var nameTFHeight: NSLayoutConstraint!
    @IBOutlet weak var dataViewHeight: NSLayoutConstraint!
    @IBOutlet weak var emailTFHeight: NSLayoutConstraint!
    @IBOutlet weak var passwordTFHeight: NSLayoutConstraint!
    
    @IBOutlet weak var activityIndicatorView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorMsgTV: UITextView!
    @IBOutlet weak var loginRegisterBTN: UIButton!
    @IBOutlet weak var loginBTN: FBSDKLoginButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var signInButton: GIDSignInButton!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    @IBOutlet weak var nameTF: UITextField!
    @IBOutlet weak var loginRegisterSegmentedControl: UISegmentedControl!
    @IBOutlet weak var orLBL: UILabel!
    @IBOutlet weak var holdingView: UIView!
    @IBOutlet weak var dataView: UIView!

    
    var emailConstraint : NSLayoutConstraint?
    var passwordConstraint : NSLayoutConstraint?
    
    
    
   
    // #MARK: - - View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        startUp()
        GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signInSilently()
        self.loginBTN.delegate = self
        self.loginBTN.readPermissions = ["public_profile" ,"email", "user_friends"]
        self.loginRegisterBTN.setTitle("Register", forState: .Normal)
        errorMsgTV.hidden = true
        self.hideActivityIndicator()
        self.insideViewOfBlurView.layer.cornerRadius = 5
        if (FBSDKAccessToken.currentAccessToken() != nil){
            gettingCredentialFromFacebook()
        }
        
    }
    
    
    // #MARK: - - Facebook protocols and Methods
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {

        if let error = error {
            print(error.localizedDescription)
            return
        }
        gettingCredentialFromFacebook()
        
        self.holdingView.layoutIfNeeded()
        
    }
    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()!.signOut()
    }
    
    func gettingCredentialFromFacebook(){
        self.displayActivityIndicator()
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        FIRAuth.auth()?.signInWithCredential(credential, completion: { (user, error) in
            
            if error != nil{
                if !self.activityIndicatorView.hidden{
                    self.hideActivityIndicator()
                }
                self.errorMsgTV.text = error?.localizedDescription
                self.errorMsgTV.hidden = false
            }
            
            self.userExistsInFirebase(user!)
//            self.toLandingPage(user!)
            
            
            
        })
        
    }
    
    
    // #MARK: - - Google protocols and Methods
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!, withError error: NSError?) {
        
        if error != nil {
            return
        }
        displayActivityIndicator()
        let authentication = user.authentication
        let credential = FIRGoogleAuthProvider.credentialWithIDToken(authentication.idToken,
                                                                     accessToken: authentication.accessToken)
        
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            // ...
            if error != nil{
                if !self.activityIndicatorView.hidden{
                    self.hideActivityIndicator()
                }
                self.errorMsgTV.text = error?.localizedDescription
                self.errorMsgTV.hidden = false
            }
            
            
            self.userExistsInFirebase(user!)
//            self.toLandingPage(user!)
            
            
        }
    }
    
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
    }
    
    
    // #MARK:- - User Check In Firebase
    func userExistsInFirebase(user:FIRUser) -> (){
        let userRef = FIRDatabase.database().reference().child("Users").child(user.uid)
        
        userRef.observeSingleEventOfType(.Value) { (snapshot:FIRDataSnapshot) in
            if !snapshot.exists(){
                self.storeUserInDatabase(user.displayName!, user: user)
                self.toSetUserDetailsPage()
            }
            else{
                self.toLandingPage()
            }
        }
       
        
    }
    
    func storeUserInDatabase(name:String, user:FIRUser) -> () {
        let userRef = FIRDatabase.database().reference().child("Users")
        var values : Dictionary = [String:String]()
        values["name"] = String(name)
        values["email"] = String(user.email!)
        values["profileImageURL"] = ""
        
        userRef.child(user.uid).setValue(values) { (error, snapshot) in
            
        }
    }
    
    
    // #MARK:- - To landing Page
    func toLandingPage(){
        
        
        let landingPageViewController  = LandingPageViewController()
        let navigation  =  UINavigationController(rootViewController: landingPageViewController)
        self.presentViewController(navigation, animated: true, completion: {
        })
        
    }
    
    
    // #MARK:- - To Set User Details
    func toSetUserDetailsPage() -> () {
        let setUserDetailsViewController = SetUserDetailsViewController()
        presentViewController(setUserDetailsViewController, animated: true, completion: nil)
    }
    
    
    // #MARK:- - Validating Email and Password
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        if emailTest.evaluateWithObject(testStr){
            return true
        }
        else{
            
            return false
        }
    }
    
    func isValidPassword(testStr:String) -> Bool{
        
        
        return testStr.characters.count>=6
    }
    
    
    // #MARK:- - Constraints Update
    func changeDataViewConstraint(){
        self.dataViewHeight.constant = -50
        self.nameTF.frame = CGRectMake(0, 0, 0, 0)
        emailConstraint = NSLayoutConstraint(
            item: self.emailTF,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: self.dataView,
            attribute: .Height,
            multiplier: 1/2,
            constant: 0)
        
        passwordConstraint = NSLayoutConstraint(
            item: self.passwordTF,
            attribute: .Height,
            relatedBy: .Equal,
            toItem: self.dataView,
            attribute: .Height,
            multiplier: 1/2,
            constant: 0)
        
        emailConstraint?.active = true
        passwordConstraint?.active = true
        
    }
    
    
    // #MARK:- - Helper ViewDidLoad
    func startUp() -> () {
        
        UIView.animateWithDuration(0.75, delay: 0, options: .CurveEaseOut, animations: {
            self.profileImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2)
        }) { (isFinished) in
            UIView.animateWithDuration(0.75, delay: 0, options: .CurveEaseOut, animations: {
                self.profileImageView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1, 1)
                }, completion: nil)
        }
        
        self.loginRegisterSegmentedControl.selectedSegmentIndex = 1
        
        self.dataView.layer.cornerRadius = 10
        
        self.errorMsgTV.frame = CGRectInset(self.errorMsgTV.frame, -2.0, -2.0);
        self.errorMsgTV.layer.borderColor = UIColor.redColor().CGColor
        self.errorMsgTV.layer.borderWidth = 2.0;
        

    }
    
    
    // #MARK:- - Login and Register
    @IBAction func loginRegisterBTNpressed(sender: AnyObject) {
        if(self.loginRegisterSegmentedControl.selectedSegmentIndex==0){
            login()
        }
        else{
            register()
        }
        
    }
    
    func login() -> () {
                displayActivityIndicator()
        guard let email = self.emailTF.text, let password = passwordTF.text where  isValidEmail(email) && isValidPassword(password) else{
            
            if !self.activityIndicatorView.hidden{
                self.hideActivityIndicator()
            }
            self.errorMsgTV.text = "Invalid Credentials"
            self.errorMsgTV.hidden = false
            return
        }
        
        FIRAuth.auth()?.signInWithEmail(email, password: password, completion: { (user, error) in
            if error != nil{
                if !self.activityIndicatorView.hidden{
                    self.hideActivityIndicator()
                }
                self.errorMsgTV.text = error?.localizedDescription
                self.errorMsgTV.hidden = false
            }
            
            self.toLandingPage()
            
            
        })
    }
    
    func register() -> () {
                displayActivityIndicator()
        guard let email = emailTF.text, let password = passwordTF.text, let name  = nameTF.text where isValidEmail(email) else{
            if !self.activityIndicatorView.hidden{
                self.hideActivityIndicator()
            }
            self.errorMsgTV.text = "Invalid Email"
            self.errorMsgTV.hidden = false
            return
        }
        
        FIRAuth.auth()?.createUserWithEmail(email, password: password, completion: { (user, error) in
            if error != nil{
                if !self.activityIndicatorView.hidden{
                    self.hideActivityIndicator()
                }
                self.errorMsgTV.text = error?.localizedDescription
                self.errorMsgTV.hidden = false
                return
            }
            user?.sendEmailVerificationWithCompletion(nil)
            self.storeUserInDatabase(name, user: user!)
            self.toSetUserDetailsPage()
//            self.toLandingPage(user!)
            
        })
        
    }
    
    
    // #MARK:- - Segment Control Action
    @IBAction func loginRegisterSegmentControlPressed(sender: AnyObject) {
        if loginRegisterSegmentedControl.selectedSegmentIndex==0{
            self.loginRegisterBTN.setTitle("Login", forState: .Normal)
            changeDataViewConstraint()
            
        }else{
            self.dataViewHeight.constant = 0
            self.emailConstraint?.active = false
            self.passwordConstraint?.active = false
            
            self.loginRegisterBTN.setTitle("Register", forState: .Normal)
        }
    }
    
    
    // #MARK:- - ActivityIndicator Methods
    func displayActivityIndicator() -> () {
        self.activityIndicatorView.hidden = false
        self.activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() -> () {
        self.activityIndicatorView.hidden = true
        self.activityIndicator.stopAnimating()
    }
    

}
