//
//  RegisterViewController.swift
//  Flare
//
//  Created by Georgia Mills on 09/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth

class RegisterViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userEmail: UITextField!
    @IBOutlet weak var userPassword: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userEmail.delegate = self;
        self.userPassword.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func createAccountAction(_ sender: UIButton) {
        if self.userEmail.text == "" || self.userPassword.text == ""
        {
            displayAlertMessage("All fields required")
            return;
        } else {
            FIRAuth.auth()?.createUser(withEmail: self.userEmail.text!, password: self.userPassword.text!, completion: { (user, error) in
                if error == nil
                {
                    self.userEmail.text = ""
                    self.userPassword.text = ""
                    
                } else {
                    self.displayAlertMessage("This is a firebase error")
                    return;
                }
                
            })
        }
    }
    
    func displayAlertMessage(_ message: String) {
        let myAlert = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
}
