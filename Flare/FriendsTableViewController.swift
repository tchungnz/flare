//
//  FriendsTableViewController.swift
//  Flare
//
//  Created by Tim Chung on 9/11/16.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import FBSDKCoreKit

class FriendsTableViewController: UITableViewController {
    
    var facebook = Facebook()
    var friends: NSDictionary?
    var friendsNames = [String]()
    var selectedFriends = [String]()
    var boolArray = [Bool]()
    
    @IBOutlet weak var inviteFriendsButton: UIBarButtonItem!
    @IBOutlet weak var selectFriendImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrieveAndSetFacebookFriends()
        self.tableView.allowsMultipleSelection = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func retrieveAndSetFacebookFriends() {
        facebook.getFacebookFriendsIdName {
            (result: NSDictionary) in
            self.friends = result
            self.selectedFriends = result.allValues as! [String]
            let unorderedFriendsNames = result.allValues as! [String]
            self.friendsNames = unorderedFriendsNames.sorted(by: { (s1: String, s2: String) -> Bool in return s2 > s1 } )
            self.friendsNames[0] = "All Friends"
            self.setBoolArray()
            self.tableView.reloadData()
        }
    }
    
    func setBoolArray() {
        boolArray = [Bool]()
        for _ in 1...friendsNames.count {
            boolArray.append(false)
        }
        boolArray[0] = true
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if friends != nil {
            return self.friendsNames.count
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendToInvite", for: indexPath) as! FriendsTableViewCell
        cell.facebookNameLabel.text = self.friendsNames[indexPath.row]
       
        if boolArray[indexPath.row] {
            cell.selectFriendImage.image = UIImage(named: "ticked")
            } else {
            cell.selectFriendImage.image = UIImage(named: "unticked")
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! FriendsTableViewCell
        
        if cell.facebookNameLabel.text == "All Friends" && cell.selectFriendImage.image == UIImage(named: "unticked") {
            selectedFriends = self.friends?.allValues as! [String]
            setBoolArray()
            self.tableView.reloadData()
        } else if cell.facebookNameLabel.text == "All Friends" && cell.selectFriendImage.image == UIImage(named: "ticked") {
            selectedFriends = [String]()
            cell.selectFriendImage.image = UIImage(named: "unticked")
            boolArray[indexPath.row] = false
        } else if cell.selectFriendImage.image == UIImage(named: "ticked") {
            cell.selectFriendImage.image = UIImage(named: "unticked")
            boolArray[indexPath.row] = false
            if let index = selectedFriends.index(of: (cell.facebookNameLabel.text)!) {
                selectedFriends.remove(at: index)
            }
        } else if cell.selectFriendImage.image == UIImage(named: "unticked") && boolArray[0] == false {
            cell.selectFriendImage.image = UIImage(named: "ticked")
            boolArray[indexPath.row] = true
            selectedFriends.append((cell.facebookNameLabel?.text)!)
        } else if cell.selectFriendImage.image == UIImage(named: "unticked") && boolArray[0] {
            selectedFriends = [String]()
            boolArray[0] = false
            boolArray[indexPath.row] = true
            selectedFriends.append((cell.facebookNameLabel?.text)!)
            self.tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveSelectedFriends" {
            if let ivc = segue.destination as? FlareViewController {
                ivc.selectedFriends = self.selectedFriends
                var selectedFriendsIds = [String]()
                for name in self.selectedFriends {
                    selectedFriendsIds.append(self.friends?.allKeys(for: name)[0] as! String)
                }
                ivc.selectedFriendsIds = selectedFriendsIds
            }
        }
    }

}

