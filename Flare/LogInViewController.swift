//
//  LogInViewController.swift
//  Flare
//
//  Created by Georgia Mills on 07/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit

class LogInViewController: UIViewController {

    @IBOutlet weak var userPasswordTextField: UITextField!
    @IBOutlet weak var userEmailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonTapped(sender: AnyObject) {
        let userEmail = userEmailTextField.text;
        let userPassword = userPasswordTextField.text;
        
        let userEmailStored = NSUserDefaults.standardUserDefaults().stringForKey("userEmail")
        let userPasswordStored = NSUserDefaults.standardUserDefaults().stringForKey("userPassword")
        
        if(userEmail == userEmailStored)
        {
            if(userPassword == userPasswordStored) {
                //login successful -- display alert message here
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isUserLoggedin")
                NSUserDefaults.standardUserDefaults().synchronize()
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }
    
}
