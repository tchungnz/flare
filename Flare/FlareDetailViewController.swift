//
//  FlareDetailViewController.swift
//  Flare
//
//  Created by Tim Chung on 10/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import Firebase
import MapKit
import FirebaseDatabase


class FlareDetailViewController: UIViewController {
    
    @IBOutlet weak var flareTitleLabel: UILabel!
    @IBOutlet weak var flareSubtitleLabel: UILabel!
    @IBOutlet weak var flareImage: UIImageView!
    
    var flareExport: Flare?

    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // MARK: How to get image out of storage
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://flare-1ef4b.appspot.com")
        let islandRef = storageRef.child("images/flare\(flareExport!.imageRef!).jpg")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            islandRef.dataWithMaxSize(1 * 1024 * 1024) { (data, error) -> Void in
                if (error != nil) {
                    print("Error!")
                } else {
                    let islandImage: UIImage! = UIImage(data: data!)
                    let flareImage = UIImageView(image: islandImage!)
                    flareImage.frame = CGRect(x: 0, y: 0, width: 100, height: 200)
                    print(flareImage)
                    self.view.addSubview(flareImage)
                    }
                }
        
        
        
//        let printTitle = aTitle
        print("*************IMAGEREF**************")
        print(flareExport!.imageRef)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
