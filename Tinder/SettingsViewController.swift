//
//  SettingsViewController.swift
//  Pretty Pretty
//
//  Created by Abid Amirali on 7/3/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

var settingsUserPicture = ""
var settingsUserName = ""

class SettingsViewController: UIViewController, FBSDKLoginButtonDelegate {

    @IBOutlet weak var userProfileImage: UIImageView!

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var fbButtonCenter: UILabel!
    @IBOutlet weak var isInterestedInWomen: UISwitch!

    let usersPath = FIRDatabase.database().reference().child("users")

    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let FBLoginButton = FBSDKLoginButton()
        FBLoginButton.center = fbButtonCenter.center
        FBLoginButton.center.x = FBLoginButton.center.x
        FBLoginButton.center.y = FBLoginButton.center.y
        FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.view.addSubview(FBLoginButton)
        FBLoginButton.delegate = self

    }

    func startSpinner() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    func stopSpinner() {
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error != nil) {
            print(error.localizedDescription)

        } else if (result.isCancelled) {

        } else {

        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        do {
            try FIRAuth.auth()?.signOut()
            print("User logged out")
//            performSegueWithIdentifier("userLoggedOut", sender: self)
            let vc = self.storyboard?.instantiateViewControllerWithIdentifier("loginScreen")
            self.presentViewController(vc!, animated: true, completion: nil)
        } catch {

        }
    }

    override func viewDidAppear(animated: Bool) {
        startSpinner()
        if (settingsUserPicture.characters.count > 0) {
            let url = NSURL(string: settingsUserPicture)
            let data = NSData(contentsOfURL: url!)
            let image = UIImage(data: data!)
            userProfileImage.image = image!
            userName.text = settingsUserName
            stopSpinner()
        }
    }

    override func viewWillDisappear(animated: Bool) {
        if (FIRAuth.auth()?.currentUser != nil) {
            if (isInterestedInWomen.on) {
                usersPath.child("\((FIRAuth.auth()?.currentUser?.uid)!)/isInterestedIn").setValue("Women")
            } else {
                usersPath.child("\(FIRAuth.auth()?.currentUser?.uid)/isInterestedIn").setValue("Men")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
