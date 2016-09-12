//
//  ViewController.swift
//  Pretty Pretty
//
//  Created by Abid Amirali on 6/29/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit

class ViewController: UIViewController, FBSDKLoginButtonDelegate {

    let databaseRef = FIRDatabase.database().reference()

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    @IBOutlet weak var fbLoginPlaceholderLabel: UILabel!

    func startSpinner() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.WhiteLarge
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        view.addSubview(activityIndicator)
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
            var alert = UIAlertController(title: "Error", message: "Could not login using facebook. Please try agin.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) in
                self.dismissViewControllerAnimated(true, completion: nil)
                }))
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            let credentials = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            FIRAuth.auth()?.signInWithCredential(credentials, completion: { (user, error) in
                if (error != nil) {
                    print(error?.localizedDescription)
                    var alert = UIAlertController(title: "Error", message: "\(error?.localizedDescription)", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) in
                        self.dismissViewControllerAnimated(true, completion: nil)
                        }))
                    self.presentViewController(alert, animated: true, completion: nil)
                } else {
                    self.startSpinner()
                    let userPath = self.databaseRef.child("/users/\((FIRAuth.auth()?.currentUser?.uid)!)")
                    userPath.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                        if let interestedIn = snapshot.value?.objectForKey("isInterestedIn") {
                            self.stopSpinner()
                            self.performSegueWithIdentifier("userHasSignedUp", sender: self)
                        } else {

                            print(user?.email)
                            let userData: [String: String] = [
                                "name": user!.displayName!,
                                "email": user!.email!,
                                "uid": (user?.uid)!,
                            ]
                            self.databaseRef.child("/users/\((user?.uid)!)").updateChildValues(userData)
                            self.getFBData("\((user?.uid)!)")
                        }
                    })

                }
            })
        }
    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {
        print("User logged out")
    }

    func getFBData(userPath: String) {
        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, gender"])
        graphRequest.startWithCompletionHandler { (connection, result, error) in
            if (error != nil) {
                print(error.localizedDescription)
            } else {
                print("printing result\n", result)
                let fbID: String = result.valueForKey("id") as! String
                let gender = result.valueForKey("gender") as! String
                let facebookProfileUrl = "https://graph.facebook.com/\(fbID)/picture?type=large"
                let userData: [String: String] = [
                    "FBID": fbID,
                    "FBProfilePicURL": facebookProfileUrl,
                    "gender": gender
                ]
                self.databaseRef.child("/users/\(userPath)").updateChildValues(userData)
                self.stopSpinner()
                self.performSegueWithIdentifier("showSignUpScreen", sender: self)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let FBLoginButton = FBSDKLoginButton()
        FBLoginButton.center = fbLoginPlaceholderLabel.center
        FBLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        self.view.addSubview(FBLoginButton)
        FBLoginButton.delegate = self

    }

    func addTestDummies() {
        let imageURLS = ["http://www.7magazine.re/photo/art/grande/8602206-13559941.jpg?v=1449042307", "http://i.imgur.com/7v0CINL.jpg", "http://backgrounds4k.net/wp-content/uploads/2016/03/Selena-Gomez-free.jpg", "http://www.billboard.com/files/styles/promo_650/public/media/hailee-steinfeld-dani-brubaker-2015-billboard-650.jpg", "https://elenasquareeyes.files.wordpress.com/2015/04/1423513270_anna-kendrick-zoom.jpg", "http://www.whitegadget.com/attachments/pc-wallpapers/152050d1410521343-mila-kunis-mila-kunis-image.jpg"]

        for i in 0 ..< imageURLS.count {
            let usersPath = FIRDatabase.database().reference().child("/users")
            let uid = usersPath.childByAutoId().key

            let userData = [
                "FBID": "0123487384\(i)",
                "FBProfilePicURL": imageURLS[i],
                "email": "test_dummy\(i)@testing.com",
                "gender": "female",
                "isInterestedIn": "Men",
                "name": "Miss Test Dummy\(i)",
                "uid": uid
            ]
            usersPath.child("\(uid)").setValue(userData)

        }

    }

    override func viewDidAppear(animated: Bool) {
//        do {
//            try FIRAuth.auth()?.signOut()
//        } catch { }
        if (FIRAuth.auth()?.currentUser != nil) {
            startSpinner()
            let userPath = databaseRef.child("/users/\((FIRAuth.auth()?.currentUser?.uid)!)")
            userPath.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
                if let interestedIn = snapshot.value?.objectForKey("isInterestedIn") {
                    self.stopSpinner()
                    self.performSegueWithIdentifier("userHasSignedUp", sender: self)
                } else {
                    self.stopSpinner()
                    self.performSegueWithIdentifier("showSignUpScreen", sender: self)
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

