//
//  RootViewController.swift
//  Flare
//
//  Created by Thomas Williams on 08/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class RootViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    var loginButton = FBSDKLoginButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.hidden = true
        FIRAuth.auth()?.addAuthStateDidChangeListener { auth, user in
            if let user = user {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let mapViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("mapView")
                self.presentViewController(mapViewController, animated: true, completion: nil)
                
            } else {
                self.loginButton.center = self.view.center
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                self.loginButton.delegate = self
                
                self.view.addSubview(self.loginButton)
                self.loginButton.hidden = false
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        print("User Logged In")
        self.loginButton.hidden = true
        if(error != nil) {
            self.loginButton.hidden = false
        } else if(result.isCancelled) {
            self.loginButton.hidden = false
        } else {
        
        let credential = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
        
        FIRAuth.auth()?.signInWithCredential(credential) { (user, error) in
            print("User Logged Into Firebase")
        }
        }
    }

    
    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User Logged Out")

    }

}
