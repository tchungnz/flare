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

class RootViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func facebookLogin(sender: AnyObject) {
        let myRootRef = Firebase(url: URL("https://flare-1ef4b.firebaseio.com"))
        let facebookLogin = FBSDKLoginManager()
        print("Logging In")
        facebookLogin.logInWithReadPermissions(["email"], fromViewController: self, handler:{(facebookResult, facebookError) -> Void in
            if facebookError != nil { print("Facebook login failed. Error \(facebookError)")
            } else if facebookResult.isCancelled { print("Facebook login was cancelled.")
            } else {
                print("You’re inz ;)")
                let accessToken = FBSDKAccessToken.currentAccessToken().tokenString
                myRootRef.authWith0AuthProvider("facebook", token: accessToken, withCompletionBLock: {error, authData in
                    if error != nil {
                        print("Login failed. \(error)")
                    } else {
                        print("Logged in! \(authData)")
                        
                        let newUser = [
                        "provider": authData.provider,
                        "displayName": authData.providerData["dosplayName"] as? NSString as? String,
                        "email": authData.providerData["email"] as? NSString as? String
                        ]
                    }
                    myRootRef.childByAppendingPath("facebookUsers")
                        .childByAppendingPath(authData.uid).setValue(newUser)
                    
                    let nextView = (self.storyboard?.instantiateInitialViewController("mapView"))! as UIViewController
                    self.presentViewController(nextView, animated: true, completion: nil)
                    
                    })
            }
        });

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
