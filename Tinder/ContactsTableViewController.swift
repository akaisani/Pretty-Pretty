//
//  ContactsTableViewController.swift
//  Pretty Pretty
//
//  Created by Abid Amirali on 7/2/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
import Firebase

class ContactsTableViewController: UITableViewController {

    var usersPath = FIRDatabase.database().reference().child("users")

    var uids = [String]()
    var userNames = [String]()
    var imageURLS = [String]()
    var imageFiles = [UIImage]()
    var userEmails = [String]()

    @IBOutlet var tasktable: UITableView!

    var activityIndicator = UIActivityIndicatorView()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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

    func getUserImages() {
        imageFiles.append(UIImage())
        for imageURL in imageURLS {
            if (imageURL.characters.count > 0) {
                let url = NSURL(string: imageURL)
                let data = NSData(contentsOfURL: url!)
                let image = UIImage(data: data!)
                imageFiles.append(image!)
            }
        }
        stopSpinner()
        tasktable.reloadData()
    }

    override func viewDidAppear(animated: Bool) {
        uids = []
        userNames = []
        imageURLS = []
        userEmails = []
        uids.append("")
        userNames.append("")
        imageURLS.append("")
        userEmails.append("")
        startSpinner()
        usersPath.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            for user in snapshot.children {
                if (user.key != FIRAuth.auth()?.currentUser?.uid) {
                    if let userAcceptedList = user.value.objectForKey("isAcceptedBy") as? String {
                        if (userAcceptedList.containsString("\((FIRAuth.auth()?.currentUser?.uid)!)")) {
                            print("contains 1")
                            if let userLiked = user.value.objectForKey("liked") as? String {
                                if (userLiked.containsString("\((FIRAuth.auth()?.currentUser?.uid)!)")) {
                                    self.uids.append("\((user.key!)!)")
                                    if let name = user.value.objectForKey("name") as? String {
                                        self.userNames.append(name)
                                    }
                                    if let url = user.value.objectForKey("FBProfilePicURL") as? String {
                                        self.imageURLS.append(url)
                                    }
                                    if let interest = user.value.objectForKey("isInterestedIn") as? String {
                                        infoInterest = interest
                                    }
                                    if let email = user.value.objectForKey("email") as? String {
                                        self.userEmails.append(email)
                                    }
                                }
                            }

                        }
//                        let wasAcceptedByArray = userAcceptedList.componentsSeparatedByString(",")
//                        if (wasAcceptedByArray.contains("\((FIRAuth.auth()?.currentUser?.uid)!)")) {
//                            print("contains 2")
//                        }
                    }

                } else {
                    if let url = user.value.objectForKey("FBProfilePicURL") as? String {
                        userImageURL = url
                    }
                }

            }
            print(self.uids)
            self.getUserImages()
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row != 0) {
            userIndex = indexPath.row - 1
            chatOtherUID = uids[indexPath.row]
            chatOtherUser = userNames[indexPath.row]
            otherUserImageURL = imageURLS[indexPath.row]
            infoUserEmail = userEmails[indexPath.row]
            performSegueWithIdentifier("toChat", sender: self)
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return uids.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)

        // Configure the cell...

        if (indexPath.row == 0) {
            cell.textLabel?.text = "Below are the users who accpeted you as well"
            cell.textLabel?.font = UIFont.systemFontOfSize(13)
        } else {
            if (imageFiles.count == userNames.count) {
                cell.textLabel?.text = userNames[indexPath.row]
                cell.imageView?.image = imageFiles[indexPath.row]
            }
        }
        return cell
    }

    /*
     // Override to support conditional editing of the table view.
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */

    /*
     // Override to support editing the table view.
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
     if editingStyle == .Delete {
     // Delete the row from the data source
     tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
     } else if editingStyle == .Insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */

    /*
     // Override to support rearranging the table view.
     override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

     }
     */

    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
