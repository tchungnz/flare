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


class FlareDetailViewController: UIViewController {
    
    @IBOutlet weak var flareTitleLabel: UILabel!
    @IBOutlet weak var flareSubtitleLabel: UILabel!
    var aTitle: MKAnnotation?
    

    override func viewDidLoad() {
        super.viewDidLoad()
//        let printTitle = aTitle
        print("*************")
        print(aTitle!.title)
        print(aTitle!.subtitle)
//        print(aTitle!.latitude)
//        print(aTitle!.imageRef)
        flareTitleLabel.text = aTitle!.title!
        flareSubtitleLabel.text = aTitle!.subtitle!

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


}
