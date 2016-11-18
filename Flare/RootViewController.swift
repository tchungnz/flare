//
//  RootViewController.swift
//  Flare
//
//  Created by Thomas Williams on 08/09/2016.
//  Copyright © 2016 appflare. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

class RootViewController: UIViewController, FBSDKLoginButtonDelegate, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    lazy var VCArr: [UIViewController] = {
        return [self.VCInstance(name: "FirstVC"),
                self.VCInstance(name: "SecondVC"),
                self.VCInstance(name: "ThirdVC")]
    }()
    
    
    private func VCInstance(name: String) -> UIViewController {
        return UIStoryboard(name: "main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    var loginButton = FBSDKLoginButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.dataSource = self
        self.delegate = self
        if let firstVC = VCArr.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        
        self.loginButton.isHidden = false
 
        FIRAuth.auth()?.addStateDidChangeListener { auth, user in
            if let user = user {
                self.saveUserToDatabase()
                let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
                let mapViewController: UIViewController = mainStoryboard.instantiateViewController(withIdentifier: "mapView")
                self.present(mapViewController, animated: true, completion: nil)
            } else {
                self.loginButton.center = self.view.center
                self.loginButton.readPermissions = ["public_profile", "email", "user_friends"]
                self.loginButton.delegate = self
                self.view.addSubview(self.loginButton)
                self.loginButton.isHidden = false
            }
        }
    }
    
    func saveUserToDatabase() {
        let facebook = Facebook()
        let ref = FIRDatabase.database().reference()
        facebook.getFacebookID()
        if let user = FIRAuth.auth()?.currentUser, let token = FIRInstanceID.instanceID().token() {
            let userRef = ref.child(byAppendingPath: "users/\(user.uid)")

            let newUser = ["facebookID": facebook.uid! as String, "tokenID": token as String, "fullname": user.displayName! as String, "email": user.email! as String, "profileURL": String(describing: user.photoURL!) as String] as [String : Any]
            userRef.setValue(newUser)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        self.loginButton.isHidden = true
        if(error != nil) {
            self.loginButton.isHidden = false
        } else if(result.isCancelled) {
            self.loginButton.isHidden = false
        } else {
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
        }
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {

    }

    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "endUserAgreementSegue" {
            if let ivc = segue.destination as? EndUserAgreementViewController {
                ivc.route = "rootView"
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = VCArr.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return VCArr.last
        }
        
        guard VCArr.count > previousIndex else {
            return nil
        }
        
        return VCArr[previousIndex]
        
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = VCArr.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        
        guard nextIndex < VCArr.count else {
            return VCArr.first
        }
        
        guard VCArr.count > nextIndex else {
            return nil
        }
        
        return VCArr[nextIndex]
        
    }
    
    
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return VCArr.count
    }
    
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstViewController = viewControllers?.first,
            let firstViewControllerIndex = VCArr.index(of: firstViewController) else {
                return 0
        }
        
        return firstViewControllerIndex
    }
    


}
