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
    @IBOutlet weak var scrollView: UIScrollView!
    
    var flareExport: Flare?

    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.scrollView.contentSize = CGSize(width:1080, height: 1920)
        
        // MARK: How to get image out of storage
        let storage = FIRStorage.storage()
        let storageRef = storage.referenceForURL("gs://flare-1ef4b.appspot.com")
        let islandRef = storageRef.child("\(flareExport!.imageRef!)")
        // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            islandRef.dataWithMaxSize(1 * 1920 * 1080) { (data, error) -> Void in
                if (error != nil) {
                    print("Error!")
                } else {
                    let islandImage: UIImage! = UIImage(data: data!)
                    self.flareImage.image = islandImage
                    print(islandImage.size)
                    }
                }
        
                flareTitleLabel.text = flareExport!.title!
                flareSubtitleLabel.text = flareExport!.subtitle!
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
