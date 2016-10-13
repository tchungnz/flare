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
import FirebaseDatabase
import SwiftyJSON
import Firebase

class ProfileViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var activeFlareLabel: UILabel!
    @IBOutlet weak var feedbackLink: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inviteFriendLink: UIButton!
    @IBOutlet weak var shareFriendLink: UIButton!
    @IBOutlet weak var friendsListText: UILabel!
    @IBOutlet weak var friendEmailAddress: UITextField!
    
    var flareArray = [Flare]()
    var facebook = Facebook()
    var firebase = Firebase()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundButtons()
        enableKeyboardDisappear()
        retrieveAndSetFacebookFriends()
        setProfilePhoto()
        setProfileName()
        setActiveFlare()
    
    }
    
    func setActiveFlare() {
        firebase.retrieveSingleValue(appendingPath: "flares", orderedByChild: "subtitle", queryEqualToValue: name.text!) {
            (result: FIRDataSnapshot) in
                let newFlare = Flare(snapshot: result)
                self.activeFlareLabel.text = newFlare.title!
        }
    }
    
    func setProfilePhoto() {
        if let user = firebase.user {
            let profilePicURL = user.photoURL
            let data = try! Data(contentsOf: profilePicURL!)
            let profilePicUI = (UIImage(data: data as Data))!
            self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2
            self.profilePic.clipsToBounds = true
            self.profilePic.image = profilePicUI
        }
    }
    
    func setProfileName() {
        if let user = firebase.user {
            name.text = user.displayName
        }
    }
    
    func retrieveAndSetFacebookFriends() {
        facebook.getFacebookFriends("name") {
            (result: [String]) in
            self.setLabelText(result)
        }
    }
    
    func enableKeyboardDisappear() {
        self.friendEmailAddress.delegate = self
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("dismissKeyboard")))
    }
    
    func setLabelText(_ result: [String]) {
        var friendNames = String()
        print(friendNames)
        friendNames = result.joined(separator: "\n- ")
        friendsListText.text = String("- " + friendNames)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logOutAction(_ sender: UIButton) {
        logout()
    }
    
    @IBAction func feedbackLink(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://flarefeedback.typeform.com/to/Bq5Sah")!)
    }
    
    @IBAction func inviteLink(_ sender: AnyObject) {
            if self.friendEmailAddress.text != "" {
                firebase.saveToDatabaseWithUniqueId(appendingPath: "email invites", value: ["email": self.friendEmailAddress.text! as String])
            } else {
                self.displayAlertMessage("Please enter an email address")
                return
            }
        }
    
    // refactor into separate class (duplicate in flareview)
    func displayAlertMessage(_ message: String)
    {
        let myAlert = UIAlertController(title: "Ooops", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let okAction = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil)
        myAlert.addAction(okAction)
        self.present(myAlert, animated: true, completion: nil)
    }
    
    // refactor into separate class (duplicate in flareview)
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    @IBAction func shareLink(_ sender: AnyObject) {
        // text to share
        let text = "Hi! Come join me on Flare by signing up to the iOS beta: www.flare.earth."
        
        // set up activity view controller
        let objectsToShare: [AnyObject] = [ text as AnyObject ]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }

    
    func roundButtons() {
        self.feedbackLink.layer.cornerRadius = 10;
        self.inviteFriendLink.layer.cornerRadius = 10;
        self.shareFriendLink.layer.cornerRadius = 10;
    }
    
    func dismissKeyboard() {
        friendEmailAddress.resignFirstResponder()
    }

}
