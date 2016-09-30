//
//  MainNavigationController.swift
//  textU
//
//  Created by Abhishek Sharma on 30/09/16.
//  Copyright © 2016 Finoit Technologies. All rights reserved.
//

import UIKit
import Firebase

class MainNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        if isUserLoggedIn(){
            let landingPageViewController = LandingPageViewController()
            viewControllers = [landingPageViewController]
        }
        else{
            performSelector(#selector(showLoginRegisterViewController), withObject: nil, afterDelay: 0.01)
        }
        
    }
    
    func isUserLoggedIn() -> Bool {
        if FIRAuth.auth()?.currentUser == nil{
            return false
        }
        else{
            return true
        }
     }
    
    func showLoginRegisterViewController() -> (){
        let loinRegisterViewController = LoginRegisterViewController()
        presentViewController(loinRegisterViewController, animated: false, completion: nil)
        
    }
}
