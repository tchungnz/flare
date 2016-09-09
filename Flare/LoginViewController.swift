//
//  LoginViewController.swift
//  Flare
//
//  Created by Georgia Mills on 08/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    @IBOutlet weak var logoutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let user = FIRAuth.auth()?.currentUser
        {
            self.logoutButton.alpha = 1.0
            self.usernameLabel.text = user.email
        }
        else {
            self.logoutButton.alpha = 0.0
            self.usernameLabel.text =  ""
        }
        
        self.userEmail.delegate = self;
        self.userPassword.delegate = self;
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func createAccountAction(sender: AnyObject)
    {
        if self.userEmail.text == "" || self.userPassword.text == ""
        {
            displayAlertMessage("All fields required")
            return;
        } else {
            FIRAuth.auth()?.createUserWithEmail(self.userEmail.text!, password: self.userPassword.text!, completion: { (user, error) in
                if error == nil
                {
                    self.logoutButton.alpha = 1.0
                    self.usernameLabel.text = user!.email
                    self.userEmail.text = ""
                    self.userPassword.text = ""
                
                } else {
                    self.displayAlertMessage("This is a firebase error")
                    return;
                }
                
            })
        }
        
        
    }

    @IBAction func loginAction(sender: AnyObject)
    {
        if self.userEmail.text == "" || self.userPassword.text == ""
        {
            displayAlertMessage("All fields required")
            return;
        } else {
            FIRAuth.auth()?.signInWithEmail(self.userEmail.text!, password: self.userPassword.text!, completion: { (user, error) in
                if error == nil
                {
                    self.logoutButton.alpha = 1.0
                    self.usernameLabel.text = user!.email
                    self.userEmail.text = ""
                    self.userPassword.text = ""
                    
                } else {
                    self.displayAlertMessage("firebase error")
                    return;
                }
            })
        }
    }
    
    @IBAction func logoutAction(sender: AnyObject)
    {
        try! FIRAuth.auth()?.signOut()
        self.usernameLabel.text = ""
        self.logoutButton.alpha = 0.0
        self.userEmail.text = ""
        self.userPassword.text = ""
    }
    
    func displayAlertMessage(message: String)
    {
        let myAlert = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.Default, handler: nil)
        myAlert.addAction(okAction)
        self.presentViewController(myAlert, animated: true, completion: nil)
    }
    
}
