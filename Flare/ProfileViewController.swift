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
import MessageUI
import Firebase


class ProfileViewController: UIViewController, UITextFieldDelegate, MFMessageComposeViewControllerDelegate {
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var feedbackLink: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inviteFriendLink: UIButton!
    @IBOutlet weak var shareFriendLink: UIButton!
    @IBOutlet weak var friendsListText: UILabel!
    @IBOutlet weak var textCEO: UIButton!
    @IBOutlet weak var endUserAgreement: UIButton!
    @IBOutlet weak var logOut: UIButton!
   
    var databaseRef: FIRDatabaseReference!
    var flareArray = [Flare]()
    var facebook = Facebook()
    var ref = FIRDatabase.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roundButtons()
        setProfilePhotoAndName()
        retrieveAndSetFacebookFriends()
        FIRAnalytics.logEvent(withName: "profile_view", parameters: nil)
        
    }
    
    func setProfilePhotoAndName() {
        if let user = FIRAuth.auth()?.currentUser {
            let profilePicURL = user.photoURL
            let data = try! Data(contentsOf: profilePicURL!)
            let profilePicUI = (UIImage(data: data as Data))!
            self.profilePic.layer.cornerRadius = 37.5
            self.profilePic.clipsToBounds = true
            self.profilePic.image = profilePicUI
            name.text = user.displayName
        }
    }
    
    func retrieveAndSetFacebookFriends() {
        facebook.getFacebookFriends("name") {
            (result: [String]) in
            self.setLabelText(result)
        }
    }
    
    func setLabelText(_ result: [String]) {
        var friendNames = String()
        friendNames = result.joined(separator: "\n")
        friendsListText.text = String(friendNames)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func logOutAction(_ sender: AnyObject) {
        logout()
    }
    
    @IBAction func feedbackLink(_ sender: AnyObject) {
        UIApplication.shared.openURL(URL(string: "https://flarefeedback.typeform.com/to/Bq5Sah")!)
        FIRAnalytics.logEvent(withName: "feedback_link", parameters: nil)

    }
    
    // refactor into separate class (duplicate in flareview)
    func displayAlertMessage(_ message: String)
    {
        let myAlert = UIAlertController(title: "Oops", message: message, preferredStyle: UIAlertControllerStyle.alert)
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
        let text = "Hi! Come join me on Flare, it lets you share and discover spontaneous moments: https://itunes.apple.com/us/app/flare-share-discover-spontaneous/id1166173727?ls=1&mt=8"
        
        // set up activity view controller
        let objectsToShare: [AnyObject] = [ text as AnyObject ]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
        FIRAnalytics.logEvent(withName: "share_link", parameters: nil)

    }

    @IBAction func textCEO(_ sender: AnyObject) {
        var messageVC = MFMessageComposeViewController()
        
        messageVC.body = "Hey Tommy";
        messageVC.recipients = ["+447876353692"]
        messageVC.messageComposeDelegate = self;
        
        self.present(messageVC, animated: false, completion: nil)
        FIRAnalytics.logEvent(withName: "text_ceo", parameters: nil)

    }
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController,
                                      didFinishWith result: MessageComposeResult) {
    // Check the result or perform other tasks.
    
    // Dismiss the message compose view controller.
    controller.dismiss(animated: true, completion: nil)
    }
    
    
    func roundButtons() {
        self.feedbackLink.layer.cornerRadius = 10;
        self.inviteFriendLink.layer.cornerRadius = 10;
        self.shareFriendLink.layer.cornerRadius = 10;
        self.logOut.layer.cornerRadius = 10;
        self.endUserAgreement.layer.cornerRadius = 10;
        self.textCEO.layer.cornerRadius = 10;

    }

}
