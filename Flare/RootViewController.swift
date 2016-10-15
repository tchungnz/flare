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
        
        self.loginButton.isHidden = true
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let mapViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "mapView")
                self.present(mapViewController, animated: true, completion: nil)
            } else {
                self.loginButton.center = self.view.center
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                self.loginButton.delegate = self
                self.view.addSubview(self.loginButton)
                self.loginButton.isHidden = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        self.loginButton.isHidden = true
        if(error != nil) {
            self.loginButton.isHidden = false
        } else if(result.isCancelled) {
            self.loginButton.isHidden = false
        } else {
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
        }
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {

    }

}
