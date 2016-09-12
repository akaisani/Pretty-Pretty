//
//  ChatViewController.swift
//
//
//  Created by Abid Amirali on 7/3/16.
//
//

import UIKit
import Firebase

var userIndex = 0
var userImageURL = ""
var otherUserImageURL = ""
var chatOtherUser = ""
var chatOtherUID = ""
class ChatViewController: UIViewController, UITableViewDelegate, UITextFieldDelegate {
//    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var messageField: UITextField!

    @IBOutlet weak var dockViewHeight: NSLayoutConstraint!
    @IBOutlet var taskTable: UITableView!

    let databaseRef = FIRDatabase.database().reference()
//    let usersPath = FIRDatabase.database().reference().child("users")
    var chatPath: FIRDatabaseReference!
    var chatUserID: String!
    var chatUserName: String!
    var messages = [String]()
    var uids = [String]()
    var msgIDS = [String]()
    var userImage = UIImage()
    var otherUserImage = UIImage()
    var activityIndicator = UIActivityIndicatorView()

    @IBAction func send(sender: AnyObject) {

        self.messageField.endEditing(true)
        if (messageField.text?.characters.count > 0) {
            pushToFirebase(messageField.text!)
        }
        messageField.text = ""
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        userImage = UIImage(data: NSData(contentsOfURL: NSURL(string: userImageURL)!)!)!
        otherUserImage = UIImage(data: NSData(contentsOfURL: NSURL(string: otherUserImageURL)!)!)!
        self.databaseRef.keepSynced(true)
        self.messageField.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "tableViewTapped")
        self.taskTable.addGestureRecognizer(tapGestureRecognizer)

    }

    override func viewDidAppear(animated: Bool) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        self.title = "\(chatOtherUser)"
//        textView.text = "Tap to enter text here"
        chatUserID = "\((FIRAuth.auth()?.currentUser?.uid)!)"
        chatUserName = "\((FIRAuth.auth()?.currentUser?.uid)!)"
        chatPath = databaseRef.child("chats").child("\(chatUserID)&&\(chatOtherUID)")

        chatPath.observeEventType(FIRDataEventType.ChildAdded, withBlock: { (snapshot) in
            if let messageText = snapshot.value?.objectForKey("msgText") as? String {
                if let uid = snapshot.value?.objectForKey("uid") as? String {
                    if let msgID = snapshot.value?.objectForKey("msgID") as? String {
                        self.messages.append(messageText)
                        self.uids.append(uid)
                        self.msgIDS.append(msgID)
                    }
                }
            }
            self.taskTable.reloadData()
        })

    }

    func keyboardWillShow(notification: NSNotification) {
        print("shown")
        if let userInfo = notification.userInfo {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size.height {
                print("in here 2")
                print(keyboardSize)
                self.view.layoutIfNeeded()
                UIView.animateWithDuration(0.5, animations: {
                    self.dockViewHeight.constant += keyboardSize
                    self.view.layoutIfNeeded()

                })
            }

        }
    }
    func keyboardWillHide(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            if let keyboardHeight = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size.height {
                UIView.animateWithDuration(0.25, animations: { () -> Void in
                    self.dockViewHeight.constant = 66
                    self.view.layoutIfNeeded()
                })
            }
        }
    }

    func tableViewTapped() {
        self.messageField.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Firebase Methods

    func pushToFirebase(message: String) {
        let idForDB = chatPath.childByAutoId().key
        let msgData = [
            "uid": (FIRAuth.auth()?.currentUser?.uid)!,
            "msgText": message,
            "msgID": idForDB
        ]
        chatPath.child("/\(idForDB)").setValue(msgData)
    }

    // MARK: tableView delegate Methods

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return messages.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("chatCell", forIndexPath: indexPath)

        // Configure the cell...
        cell.textLabel?.text = messages[indexPath.row]
        if (uids[indexPath.row] == (FIRAuth.auth()?.currentUser?.uid)!) {

            cell.imageView?.image = userImage
            cell.contentView.transform = CGAffineTransformMakeScale(-1, 1)
            cell.imageView?.transform = CGAffineTransformMakeScale(-1, 1)
            cell.textLabel?.transform = CGAffineTransformMakeScale(-1, 1)
            cell.textLabel?.textAlignment = NSTextAlignment.Right
            cell.backgroundColor = UIColor.init(colorLiteralRed: 102 / 225.0, green: 153 / 225.0, blue: 102 / 225.0, alpha: 0.4)
            cell.textLabel?.backgroundColor = UIColor.clearColor()
        } else {

            cell.imageView?.image = otherUserImage
            cell.backgroundColor = UIColor.init(colorLiteralRed: 102 / 225.0, green: 153 / 225.0, blue: 151 / 225.0, alpha: 0.4)
            cell.textLabel?.backgroundColor = UIColor.clearColor()
        }

        return cell
    }
}

