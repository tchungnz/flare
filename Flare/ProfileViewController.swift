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


class ProfileViewController: UIViewController {
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var activeFlareLabel: UILabel!
    
    var databaseRef: FIRDatabaseReference!
    var flareArray = [Flare]()


    override func viewDidLoad() {
        super.viewDidLoad()

        if let user = FIRAuth.auth()?.currentUser {
            let profilPicURL = user.photoURL
            
            let data = NSData(contentsOfURL: profilPicURL!)
            let profilePicUI = UIImage(data: data!)
            self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width/2
            self.profilePic.clipsToBounds = true
            self.profilePic.image = profilePicUI
            name.text = user.displayName
            username.text = user.email
            
        }
        
        databaseRef = FIRDatabase.database().reference().child("flares")
        databaseRef.queryOrderedByChild("subtitle").queryStartingAtValue(username.text).queryLimitedToLast(1).observeEventType(.Value, withBlock: { (snapshot) in
            
            
            var newItems = [Flare]()
            for item in snapshot.children {
                print(item)
                let newFlare = Flare(snapshot: item as! FIRDataSnapshot)
                newItems.insert(newFlare, atIndex: 0)
            }
            
            self.flareArray = newItems
            self.activeFlareLabel.text = self.flareArray.first!.title
//            print(self.flareArray)
        
        })
        { (error) in
            print(error.localizedDescription)
        }
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
