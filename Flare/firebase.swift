//
//  firebase.swift
//  Flare
//
//  Created by Tim Chung on 12/10/16.
//  Copyright © 2016 appflare. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class Firebase: NSObject {
    
    var ref = FIRDatabase.database().reference()
    var user = FIRAuth.auth()?.currentUser
    var jsonObject: NSDictionary?
    
    
    func saveToDatabaseWithUniqueId(appendingPath: String, value: NSDictionary) {
        let newRef = ref.child(byAppendingPath: appendingPath).childByAutoId()
        newRef.setValue(value)
    }
    
    
    func saveToDatabaseWithoutUniqueId(appendingPath: String, value: NSDictionary, databaseId: String) {
        let newRef = ref.child(byAppendingPath: appendingPath).child(databaseId)
        newRef.setValue(value)
    }
    
    
    func retrieveSingleValue(appendingPath: String, orderedByChild: String, queryEqualToValue: String) {
        let newRef = ref.child(byAppendingPath: appendingPath)
        newRef.queryOrdered(byChild: orderedByChild).queryEqual(toValue: queryEqualToValue).queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
            
            for item in snapshot.children {
                self.jsonObject = (item as AnyObject).valueInExportFormat() as! NSDictionary
            }
            })
        { (error) in
            print(error.localizedDescription)
        }
        
    }
    

}
