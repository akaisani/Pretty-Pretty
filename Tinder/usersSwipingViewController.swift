//
//  usersSwipingViewController.swift
//  Pretty Pretty
//
//  Created by Abid Amirali on 7/1/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation

class usersSwipingViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var userImage: UIImageView!

    @IBOutlet weak var userName: UILabel!

    @IBOutlet weak var didAcceptLabel: UILabel!

    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()

    var userGenders = [String: String]()

    var userInterests = [String: String]()

    var usersPath = FIRDatabase.database().reference().child("users")

    var userNames = [String]()

    var imageURLS = [String]()

    var currentUserInterest = ""

    var uids = [String]()

    var currentUsersGender = ""

    var imageFiles = [UIImage]()

    var imageCenter: CGPoint!

    var positionInUsers = 0

    var likedString = ""

    var dislikedString = ""

    var isAcceptedByArray = [String]()

    var isRejectedByArray = [String]()

    var timer = NSTimer()

    var count = 0

    var userLocationString = ""

    var manager = CLLocationManager()

    var lattitudeOfUsers = [CLLocationDegrees]()

    var longitudeOfUsers = [CLLocationDegrees]()

    func startSpinner() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 80, 80))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        activityIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5)
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

    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print(error.localizedDescription)
    }

    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations[0] as CLLocation
        let userLattitude = userLocation.coordinate.latitude
        let userLongitude = userLocation.coordinate.longitude
        userLocationString = "\(userLongitude),\(userLattitude)"
        usersPath.child("\((FIRAuth.auth()?.currentUser?.uid)!)/location").setValue(userLocationString)
        manager.stopUpdatingLocation()
        var removedNum = 0
//        let longitude = CLLocationDegrees()
//        let lattitude = CLLocationDegrees()
        // sorting users by close proximity
        for i in 0 ..< longitudeOfUsers.count {
            var longDifference = longitudeOfUsers[i - removedNum] - userLongitude
            if (longDifference < 0) {
                longDifference = -longDifference
            }
            var lattDiffernce = lattitudeOfUsers[i - removedNum] - userLattitude
            if (lattDiffernce < 0) {
                lattDiffernce = -lattDiffernce
            }
            if (lattDiffernce > 10 || longDifference > 10) {
                uids.removeAtIndex(i - removedNum)
                imageURLS.removeAtIndex(i - removedNum)
                userNames.removeAtIndex(i - removedNum)
                isRejectedByArray.removeAtIndex(i - removedNum)
                isAcceptedByArray.removeAtIndex(i - removedNum)
                longitudeOfUsers.removeAtIndex(i - removedNum)
                lattitudeOfUsers.removeAtIndex(i - removedNum)
                removedNum += 1
            }
        }
        sortUsersByInterest()
    }

    func getUserLocation() {
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        imageCenter = userImage.center
        let gesture = UIPanGestureRecognizer(target: self, action: Selector("wasDragged:"))
        userImage.addGestureRecognizer(gesture)
        userImage.userInteractionEnabled = true
        // Do any additional setup after loading the view.
    }

    func updateImage() {
        if (positionInUsers < userNames.count) {
            userImage.image = imageFiles[positionInUsers]
            userName.text = userNames[positionInUsers]
            positionInUsers += 1
        } else {
            userImage.layer.borderWidth = 0
            userImage.layer.borderColor = UIColor.clearColor().CGColor
            userName.font = UIFont.systemFontOfSize(15)
            userName.text = "We are out of users currently. Pull to refresh or check again later"
            userImage.userInteractionEnabled = false
            userImage.image = nil

        }

    }

    func stopTimer() {
        count += 1
        if (count == 3) {
            timer.invalidate()
            count = 0
            didAcceptLabel.text = ""
        }
    }

    func startTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("stopTimer"), userInfo: nil, repeats: true)

    }

    func didAcceptUser() {
        let index = positionInUsers - 1
        didAcceptLabel.text = "You accepted \(userNames[index])"
        let currUser = (FIRAuth.auth()?.currentUser?.uid)!
        let selectedUser = uids[index]
//        self.usersPath.child("\(se)/wasAcceptedBy").setValue("\()")
//        likedString += "\(uids[positionInUsers - 1]),"
//        self.usersPath.child("\((FIRAuth.auth()?.currentUser?.uid)!)/liked").setValue(likedString)
        var isAcceptedString = ""
        if (isAcceptedByArray.count > index) {
            isAcceptedString = isAcceptedByArray[index]
        } else {
            isAcceptedString = ""
        }
        isAcceptedString += "\(currUser),"
        if (isAcceptedByArray.count > index) {
            isAcceptedByArray[index] = isAcceptedString
        } else {
            isAcceptedByArray.append(isAcceptedString)
        }
        likedString += "\(selectedUser),"
        self.usersPath.child("\(selectedUser)/isAcceptedBy").setValue(isAcceptedString)
        self.usersPath.child("\(currUser)/liked").setValue(likedString)
        updateImage()
        startTimer()

    }

    func didRejecUser() {
        let index = positionInUsers - 1
        didAcceptLabel.text = "You accepted \(userNames[index])"
        let currUser = (FIRAuth.auth()?.currentUser?.uid)!
        let selectedUser = uids[index]
        var isRejectedString = ""
        if (isRejectedByArray.count > index) {
            isRejectedString = isRejectedByArray[index]
        } else {
            isRejectedString = ""
        }
        isRejectedString += "\(currUser),"
        if (isRejectedByArray.count > index) {
            isRejectedByArray[index] = isRejectedString
        } else {
            isRejectedByArray.append(isRejectedString)
        }
        likedString += "\(selectedUser),"
        self.usersPath.child("\(selectedUser)/isRejectedBy").setValue(isRejectedString)
        self.usersPath.child("\(currUser)/disliked").setValue(likedString)
        updateImage()
        startTimer()

    }

    func wasDragged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self.view)
        userImage.center = CGPoint(x: imageCenter.x + translation.x, y: imageCenter.y + translation.y)
        let xFromCenter = userImage.center.x - self.imageCenter.x
        let scale = min(100 / abs(xFromCenter), 1)
        var rotation = CGAffineTransformMakeRotation(xFromCenter / 200)
        var stretch = CGAffineTransformScale(rotation, scale, scale)
        userImage?.transform = stretch
        if (gesture.state == UIGestureRecognizerState.Ended) {

            if (userImage?.center.x < 65) {
//                print(userImage?.center.x)
                print("not chosen")
                didRejecUser()
            } else if (userImage?.center.x > imageCenter.x + 100) {
//                print(userImage?.center.x)
                print("chosen")
                didAcceptUser()
            } else {
//                print(userImage?.center.x)
                print("undecided")
            }

            rotation = CGAffineTransformMakeRotation(0)
            stretch = CGAffineTransformScale(rotation, 1, 1)
            userImage?.transform = stretch
            userImage?.center = imageCenter

        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getUserImages() {
        for imageURL in imageURLS {
            let url = NSURL(string: imageURL)
            let data = NSData(contentsOfURL: url!)
            let image = UIImage(data: data!)
            imageFiles.append(image!)
        }

        self.stopSpinner()
        updateImage()
    }

    func sortUsersByInterest() {
        print(userLocationString)
        var prefferedGender = ""
        var genderRef = ""
        var otherUsersInterest = ""
        if (currentUserInterest == "Men") {
            prefferedGender = "male"
            genderRef = "female"
//            otherUsersInterests = "Women"
        } else {
            prefferedGender = "female"
            genderRef = "male"
        }
        var removedNum = 0
        // sorting users by gender desired
        for i in 0 ..< uids.count {
            if (userGenders[uids[i - removedNum]] != prefferedGender) {

                uids.removeAtIndex(i - removedNum)
                imageURLS.removeAtIndex(i - removedNum)
                userNames.removeAtIndex(i - removedNum)
                isRejectedByArray.removeAtIndex(i - removedNum)
                isAcceptedByArray.removeAtIndex(i - removedNum)
                longitudeOfUsers.removeAtIndex(i - removedNum)
                lattitudeOfUsers.removeAtIndex(i - removedNum)
                removedNum += 1
            }
        }

        // sorting users by interests
        removedNum = 0
        for i in 0 ..< uids.count {
            if (userInterests[uids[i - removedNum]] == "Men") {
                otherUsersInterest = "male"
            } else {
                otherUsersInterest = "female"
            }
            if (currentUsersGender != otherUsersInterest) {
                uids.removeAtIndex(i - removedNum)
                imageURLS.removeAtIndex(i - removedNum)
                userNames.removeAtIndex(i - removedNum)
                isRejectedByArray.removeAtIndex(i - removedNum)
                isAcceptedByArray.removeAtIndex(i - removedNum)
                longitudeOfUsers.removeAtIndex(i - removedNum)
                lattitudeOfUsers.removeAtIndex(i - removedNum)
                removedNum += 1
            }
        }

        let templikedArray = likedString.componentsSeparatedByString(",")
//        let tempwasRejected = wasRejectedBy.componentsSeparatedByString(",")
//        let tempwasAccepted = wasAcceptedBy.componentsSeparatedByString(",")
        let tempdislikedArray = dislikedString.componentsSeparatedByString(",")
        removedNum = 0
        // sorting users by previous selection
        for i in 0 ..< uids.count {
            if (templikedArray.contains(uids[i - removedNum]) || tempdislikedArray.contains(uids[i - removedNum])) {
                print(i)
                print("priting with edit:::", i - removedNum)
//                let removeIndex = uids.indexOf(uids[i - removedNum])
                uids.removeAtIndex(i - removedNum)
                imageURLS.removeAtIndex(i - removedNum)
                userNames.removeAtIndex(i - removedNum)
                isRejectedByArray.removeAtIndex(i - removedNum)
                isAcceptedByArray.removeAtIndex(i - removedNum)
                longitudeOfUsers.removeAtIndex(i - removedNum)
                lattitudeOfUsers.removeAtIndex(i - removedNum)
                removedNum += 1
            }

        }
        getUserImages()
    }

    override func viewDidAppear(animated: Bool) {
        userImage.layer.borderWidth = 2
        userImage.layer.borderColor = UIColor.whiteColor().CGColor
        userName.text = ""
        didAcceptLabel.text = ""
        startSpinner()
        usersPath.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            for user in snapshot.children {
                if (user.key! != FIRAuth.auth()?.currentUser?.uid) {
                    if let uid = user.value.objectForKey("uid") as? String {
                        if let gender = user.value.objectForKey("gender") as? String {
                            if let interest = user.value.objectForKey("isInterestedIn") as? String {
                                if let url = user.value.objectForKey("FBProfilePicURL") as? String {
                                    if let userName = user.value.objectForKey("name") as? String {
                                        self.userGenders[uid] = gender
                                        self.userInterests[uid] = interest
                                        self.uids.append(uid)
                                        self.imageURLS.append(url)
                                        self.userNames.append(userName)
                                        if let databaseAcceptedBy = user.value.objectForKey("isAcceptedBy") as? String {
                                            self.isAcceptedByArray.append(databaseAcceptedBy)
                                        } else {
                                            self.isAcceptedByArray.append("")
                                        }
                                        if let databaseRejectedBy = user.value.objectForKey("isRejectedBy") as? String {
                                            self.isRejectedByArray.append(databaseRejectedBy)
                                        } else {
                                            self.isRejectedByArray.append("")
                                        }
                                        if let userLocation = user.value.objectForKey("location") as? String {
                                            let locationArray = userLocation.componentsSeparatedByString(",")
                                            if let longitude: CLLocationDegrees = CLLocationDegrees(locationArray[0]) {
                                                self.longitudeOfUsers.append(longitude)

                                            }
                                            if let lattitude: CLLocationDegrees = CLLocationDegrees(locationArray[1]) {
                                                self.lattitudeOfUsers.append(lattitude)
                                            }
                                        }
                                    }
                                }
                            }

                        }
                    }

                } else {
                    if let interestedIn = user.value.objectForKey("isInterestedIn") as? String {
                        self.currentUserInterest = interestedIn
                    }
                    if let databaseLikedString = user.value.objectForKey("liked") as? String {
                        self.likedString = databaseLikedString
                    }
                    if let databaseDislikedString = user.value.objectForKey("disliked") as? String {
                        self.dislikedString = databaseDislikedString
                    }
                    if let gender = user.value.objectForKey("gender") as? String {
                        self.currentUsersGender = gender
                    }
                    if let name = user.value.objectForKey("name") as? String {
                        settingsUserName = name
                    }
                    if let url = user.value.objectForKey("FBProfilePicURL") as? String {
                        settingsUserPicture = url
                    }

                }
            }
            print(self.userNames)
            self.getUserLocation()

        })
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.

    }

}
