import Foundation
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Firebase

extension ProfileViewController:FBSDKAppInviteDialogDelegate {
    //MARK: FBSDKAppInviteDialogDelegate
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]) {
    }
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
    }
    
    
    @IBAction func inviteLink(_ sender: AnyObject) {
        FIRAnalytics.logEvent(withName: "facebook_invite", parameters: nil)
        let content = FBSDKAppInviteContent()
        content.appLinkURL = NSURL(string: "https://fb.me/1602056276767300") as URL!
        content.appInvitePreviewImageURL = NSURL(string: "https://firebasestorage.googleapis.com/v0/b/flare-1ef4b.appspot.com/o/flarebrand%2Fflare%20facebook%20cover.png?alt=media&token=68414c45-6200-41fc-9c62-24c8ab1d0f91")! as URL!
        FBSDKAppInviteDialog.show(from: self, with: content, delegate: self)
    }
}
