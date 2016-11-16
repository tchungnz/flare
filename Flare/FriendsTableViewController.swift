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
            orderAlphabeticallyAndAddAllFriends()
            self.tableView.reloadData()
        }
    }
    
    func orderAlphabeticallyAndAddAllFriends() {
        var unorderedFriendsNames = result.allValues as! [String]
        self.friendsNames = unorderedFriendsNames.sorted(by: { (s1: String, s2: String) -> Bool in return s2 > s1 } )
        self.friendsNames[0] = "All Friends"
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
        if cell.facebookNameLabel.text == "All Friends" {
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
            selectedFriends = friends?.allValues
            cell.selectFriendImage.image = UIImage(named: "ticked")
            for row in 2...self.friendsNames.count {
                let cell = tableView.cellForRow(at: NSIndexPath(row: row, section: 1) as IndexPath) as! FriendsTableViewCell
                cell.selectFriendImage.image = UIImage(named: "unticked")
            }
        } else if cell.facebookNameLabel.text == "All Friends" && cell.selectFriendImage.image == UIImage(named: "ticked") {
            selectedFriends = [String]()
            cell.selectFriendImage.image = UIImage(named: "unticked")
        } else if cell.selectFriendImage.image == UIImage(named: "ticked") {
            cell.selectFriendImage.image = UIImage(named: "unticked")
            if let index = selectedFriends.index(of: (cell.facebookNameLabel.text)!) {
                selectedFriends.remove(at: index)
            }
        } else {
            cell.selectFriendImage.image = UIImage(named: "ticked")
            selectedFriends.append((cell.facebookNameLabel?.text)!)
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
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
}
