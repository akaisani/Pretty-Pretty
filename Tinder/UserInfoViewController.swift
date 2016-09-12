//
//  UserInfoViewController.swift
//  Pretty Pretty
//
//  Created by Abid Amirali on 7/7/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit

var infoInterest = ""
var infoUserEmail = ""
class UserInfoViewController: UIViewController {

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var userImage: UIImageView!

    @IBOutlet weak var interestLabel: UILabel!

    var activityIndicator = UIActivityIndicatorView()

    // MARK: View setup

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        self.startSpinner()
        activityIndicator.startAnimating()
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            self.userNameLabel.text = chatOtherUser
            let url = NSURL(string: otherUserImageURL)
            let data = NSData(contentsOfURL: url!)
            let image = UIImage(data: data!)
            self.userImage.image = image!
            self.interestLabel.text = infoInterest
            self.activityIndicator.stopAnimating()
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.activityIndicator.stopAnimating()
//            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func email(sender: AnyObject) {
//        let urlString =
        let url = NSURL(string: "mailto:" + infoUserEmail)
        print(url)
        UIApplication.sharedApplication().openURL(url!)
    }

    // MARK: Spinner Methods

    func startSpinner() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    func stopSpinner() {
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
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
