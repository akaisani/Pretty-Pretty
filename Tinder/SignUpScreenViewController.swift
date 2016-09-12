//
//  SignUpScreenViewController.swift
//  Pretty Pretty
//
//  Created by Abid Amirali on 7/1/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
import Firebase

class SignUpScreenViewController: UIViewController {

    let usersPath = FIRDatabase.database().reference().child("/users")

    @IBOutlet weak var userProfileImage: UIImageView!

    @IBOutlet weak var isInterstedInWomen: UISwitch!

    @IBAction func signUp(sender: AnyObject) {
        if (isInterstedInWomen.on) {
            usersPath.child("\((FIRAuth.auth()?.currentUser?.uid)!)/isInterestedIn").setValue("Women")
        } else {
            usersPath.child("\(FIRAuth.auth()?.currentUser?.uid)/isInterestedIn").setValue("Men")
        }
        performSegueWithIdentifier("signedUpUser", sender: self)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

//        let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: nil)
//        graphRequest.startWithCompletionHandler { (connection, result, error) in
//            if (error != nil) {
//                print(error.localizedDescription)
//            } else {
//
//            }
//        }

        // Do any additional setup after loading the view.

        usersPath.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            for user in snapshot.children {
                if (user.key! == FIRAuth.auth()?.currentUser?.uid) {

                    if let fbURLString: String = user.value.objectForKey("FBProfilePicURL") as? String {
                        let imageURL = NSURL (string: fbURLString)
                        let imageData = NSData(contentsOfURL: imageURL!)
                        self.userProfileImage.image = UIImage(data: imageData!)
                    }

                }

            }
        })

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
