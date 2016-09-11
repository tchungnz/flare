//
//  ProfileViewController.swift
//  Flare
//
//  Created by Mali McCalla on 11/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKCoreKit

class ProfileViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func logOutAction(sender: UIButton) {
        let user = FIRAuth.auth()?.currentUser
        try! FIRAuth.auth()?.signOut()
        FBSDKAccessToken.setCurrentAccessToken(nil)
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let RootViewController: UIViewController = mainStoryboard.instantiateViewControllerWithIdentifier("rootView")
        self.presentViewController(RootViewController, animated: true, completion: nil)
        //        self.performSegueWithIdentifier("rootViewSeque", sender: self)
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
