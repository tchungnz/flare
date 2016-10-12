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

class ProfileViewController: UIViewController {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var activeFlareLabel: UILabel!
    @IBOutlet weak var feedbackLink: UIButton!
    @IBOutlet weak var friendsListTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var inviteFriendLink: UIButton!
    @IBOutlet weak var shareFriendLink: UIButton!
    @IBOutlet weak var friendEmailText: UITextField!
    
    var databaseRef: FIRDatabaseReference!
    var flareArray = [Flare]()
    var facebook = Facebook()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize.height = 1000
        
        facebook.getFacebookFriends("name") {
            (result: Array<String>) in
            self.setLabelText(result)
        }
        
        if let user = FIRAuth.auth()?.currentUser {
            let profilePicURL = user.photoURL
            let data = try! Data(contentsOf: profilePicURL!)
            let profilePicUI = (UIImage(data: data as Data))!
            self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2
            self.profilePic.clipsToBounds = true
            self.profilePic.image = profilePicUI
            name.text = user.displayName
        }
        
        databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrdered(byChild: "subtitle").queryEqual(toValue: name.text).queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
            
            for item in snapshot.children {
                let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
                self.activeFlareLabel.text = newFlare.title!
            }
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
    func setLabelText(_ result: Array<String>) {
        var friendNames = String()
        friendNames = result.joined(separator: "\n- ")
        friendsListTextView.text = String("- " + friendNames)
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

}
