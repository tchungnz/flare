//
//  OnboardingViewController.swift
//  Flare
//
//  Created by Mali McCalla on 18/11/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var imageBackground: UIImageView!
    
    var pageIndex: Int?
    var imageName : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageBackground.image = UIImage(named: imageName)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
