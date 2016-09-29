//
//  LandingPageViewController.swift
//  textU
//
//  Created by Abhishek Sharma on 24/09/16.
//  Copyright © 2016 Finoit Technologies. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class Message{
    var message : String?
    var userID : String?
    
}


class LandingPageViewController: UIViewController {
    var user : FIRUser?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        user = FIRAuth.auth()?.currentUser
        self.navigationController?.navigationBar.hidden = false
        self.navigationController?.navigationBar.backgroundColor = UIColor.purpleColor()
        let btnName = UIButton()
        btnName.setImage(UIImage(named: "ic_exit_to_app_white"), forState: .Normal)
        btnName.frame = CGRectMake(0, 0, 30, 30)
        btnName.tintColor = UIColor.blackColor()
        btnName.addTarget(self, action: #selector(LandingPageViewController.logoutPressed), forControlEvents: .TouchUpInside)
        let rightBarButton = UIBarButtonItem()
        rightBarButton.customView = btnName
        self.navigationItem.rightBarButtonItem = rightBarButton
        self.checkIfUserIsLoggedIn()
        
        
        
    }
    
    func checkIfUserIsLoggedIn() -> () {
        if user?.uid == nil{
            let loginRegisterViewController = LoginRegisterViewController()
            self.presentViewController(loginRegisterViewController, animated: true, completion: nil)
        }
        
        
    }
    
    
    func logoutPressed() -> () {
        
        do{
            try FIRAuth.auth()?.signOut()
            GIDSignIn.sharedInstance().signOut()
            GIDSignIn.sharedInstance().disconnect()
            FBSDKLoginManager().logOut()
            FBSDKAccessToken.setCurrentAccessToken(nil)
            let loginRegisterViewController = LoginRegisterViewController()
            self.presentViewController(loginRegisterViewController, animated: true, completion: nil)
        }catch{
            print("Error")
        }
     
    }


    

}