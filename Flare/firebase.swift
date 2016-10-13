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
    var snapshotObject: FIRDataSnapshot?
    var snapshotObjectArray = [FIRDataSnapshot]()
    var dataObject: NSDictionary?
    
    
    func saveToDatabaseWithUniqueId(appendingPath: String, value: NSDictionary) {
        let newRef = ref.child(byAppendingPath: appendingPath).childByAutoId()
        newRef.setValue(value)
    }
    
    
    func saveToDatabaseWithoutUniqueId(appendingPath: String, value: NSDictionary, databaseId: String) {
        let newRef = ref.child(byAppendingPath: appendingPath).child(databaseId)
        newRef.setValue(value)
    }
    
    
    func retrieveSingleValue(appendingPath: String, orderedByChild: String, queryEqualToValue: String, completion: @escaping (_ result: FIRDataSnapshot) -> ())  {
        let newRef = ref.child(byAppendingPath: appendingPath)
        newRef.queryOrdered(byChild: orderedByChild).queryEqual(toValue: queryEqualToValue).queryLimited(toLast: 1).observe(.value, with: { (snapshot) in
            for item in snapshot.children {
                self.snapshotObject = item as! FIRDataSnapshot
            }
            completion(self.snapshotObject!)
        })
        { (error) in
            print(error.localizedDescription)
        }
    }
    
//    func retrieveMultipleValues(appendingPath: String, orderedByChild: String, queryStartingValue: String, completion: @escaping (_ result: Array<Flare>) -> ()) {
//        let newRef = ref.child(byAppendingPath: appendingPath)
//        newRef.queryOrdered(byChild: orderedByChild).queryStarting(atValue: queryStartingValue).observe(.value, with: { (snapshot) in
//            var newItems = [Flare]()
//            
//            for item in snapshot.children {
//                
//                let data = (item as! FIRDataSnapshot).value! as! NSDictionary
//                self.dataObject = data
//                self.snapshotObjectArray.insert(item as! FIRDataSnapshot, at: 0)
//                
//                if (data["isPublic"] as! Bool) {
//                    let flare = Flare(snapshot: item as! FIRDataSnapshot)
//                    newItems.insert(flare, at: 0)
//                }
//            }
//            completion(newItems)
//            })
//        { (error) in
//            print(error.localizedDescription)
//        }
//    }
    

}
