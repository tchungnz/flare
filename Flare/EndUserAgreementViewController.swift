//
//  EndUserAgreementViewController.swift
//  Flare
//
//  Created by Tim Chung on 27/10/16.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit

class EndUserAgreementViewController: UIViewController {
    
    var route: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clickBackButton(_ sender: AnyObject) {
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        if route == "rootView" {
            let endUserAgreementController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "rootView")
            self.present(endUserAgreementController, animated: true, completion: nil)
        } else {
            let profileViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "profileView")
            self.present(profileViewController, animated: true, completion: nil)
        }
        
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
