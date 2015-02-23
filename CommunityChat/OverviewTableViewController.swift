//
//  OverviewTableViewController.swift
//  CommunityChat
//
//  Created by Ziyang Tan on 2/20/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class OverviewTableViewController: UITableViewController {

    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBOutlet weak var choosePartnerButton: UIBarButtonItem!
    
    var rooms = [PFObject]()
    var users = [PFUser]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.setLeftBarButtonItem(logoutButton, animated: false)
        self.navigationItem.setRightBarButtonItem(choosePartnerButton, animated: false)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if PFUser.currentUser() != nil {
            loadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "displayPushMessage:", name: "displayMessage", object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:"displayMessage", object:nil)
    }
    
    func displayPushMessage(notification:NSNotification) {
        let notificationDict = notification.object as NSDictionary
        
        if let aps = notificationDict.objectForKey("aps") as? NSDictionary {
            let messageText = aps.objectForKey("alert") as String
            
            let alert = UIAlertController(title: "New Message", message: messageText, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Thanks...", style: UIAlertActionStyle.Default, handler: nil))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
            // Refresh table view when new push message comes (added by Ziyang)
//            if PFUser.currentUser() != nil {
//                loadData()
//            }
        }
    }
    
    func loadData() {
        rooms = [PFObject]()
        users = [PFUser]()
        
        self.tableView.reloadData()
        
        let pred = NSPredicate(format: "user1 = %@ OR user2 = %@", PFUser.currentUser(), PFUser.currentUser())
        
        let roomQuery = PFQuery(className: "Room", predicate: pred)
        roomQuery.orderByDescending("lastUpdate")
        roomQuery.includeKey("user1")
        roomQuery.includeKey("user2")
        
        
        roomQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]!, error:NSError!) -> Void in
            if error == nil {
                self.rooms = results as [PFObject]
                
                for room in self.rooms {
                    let user1 = room.objectForKey("user1") as PFUser
                    let user2 = room["user2"] as PFUser
                    
                    if user1.objectId != PFUser.currentUser().objectId {
                        self.users.append(user1)
                    }
                    
                    if user2.objectId != PFUser.currentUser().objectId {
                        self.users.append(user2)
                    }
                }
                
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source
  
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as OverViewTableViewCell
        cell.newMessageIndicator.hidden = true
        
        let targetUser = users[indexPath.row]
        
        cell.nameLabel.text = targetUser.username
        
        let user1 = PFUser.currentUser()
        let user2 = users[indexPath.row]
        
        let profileImageFile = user2["profileImage"] as PFFile
        
        profileImageFile.getDataInBackgroundWithBlock { (data:NSData!, error:NSError!) -> Void in
            if error == nil {
                cell.profileImage.image = UIImage(data:data)
            }
        }
        
        
        let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1, user2, user2, user1)
        
        let roomQuery = PFQuery(className: "Room", predicate: pred)
        
        roomQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]!, error:NSError!) -> Void in
            if error == nil {
                if results.count > 0 {
                    let messageQuery = PFQuery(className: "Message")
                    let room = results.last as PFObject
                    
                    // New Message available
                    let unreadQuery = PFQuery(className: "UnreadMessage")
                    unreadQuery.whereKey("user", equalTo: PFUser.currentUser())
                    unreadQuery.whereKey("room", equalTo: room)
                    
                    unreadQuery.findObjectsInBackgroundWithBlock({ (results:[AnyObject]!, error:NSError!) -> Void in
                        if error == nil {
                            if results.count > 0 {
                                cell.newMessageIndicator.hidden = false
                            }
                        }
                    })
                    
                    messageQuery.whereKey("room", equalTo: room)
                    messageQuery.limit = 1
                    messageQuery.orderByDescending("createdAt")
                    messageQuery.findObjectsInBackgroundWithBlock({ (results:[AnyObject]!, error:NSError!) -> Void in
                        if error == nil {
                            if results.count > 0 {
                                let message = results.last as PFObject
                                
                                cell.lastMessageLabel.text = message["content"] as? String
                                
                                let date = message.createdAt
                                let interval = NSDate().daysAfterDate(date)
                                
                                var dateString = ""
                                
                                if interval == 0 {
                                    dateString = "Today"
                                } else if interval == 1 {
                                    dateString = "Yesterday"
                                } else if interval > 1 {
                                    let dateFormat = NSDateFormatter()
                                    dateFormat.dateFormat = "mm/dd/yyyy"
                                    dateString = dateFormat.stringFromDate(message.createdAt)
                                }
                                
                                cell.dateLabel.text = dateString as String
                            } else {
                                cell.lastMessageLabel.text = "No Messages yet"
                            }
                        }
                    })
                }
            }
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let messagesVC = sb.instantiateViewControllerWithIdentifier("MessagesViewController") as MessagesViewController
        
        let user1 = PFUser.currentUser()
        let user2 = users[indexPath.row]
        
        let pred = NSPredicate(format: "user1 = %@ AND user2 = %@ OR user1 = %@ AND user2 = %@", user1, user2, user2, user1)
        
        let roomQuery = PFQuery(className: "Room", predicate: pred)
        
        roomQuery.findObjectsInBackgroundWithBlock { (results:[AnyObject]!, error:NSError!) -> Void in
            if error == nil {
                let room = results.last as PFObject
                messagesVC.room = room
                messagesVC.incomingUser = user2
                
                let unreadQuery = PFQuery(className: "UnreadMessage")
                unreadQuery.whereKey("user", equalTo: PFUser.currentUser())
                unreadQuery.whereKey("room", equalTo: room)
                
                unreadQuery.findObjectsInBackgroundWithBlock({ (results:[AnyObject]!, error:NSError!) -> Void in
                    if error == nil {
                        if results.count > 0 {
                            let unreadMessages = results as [PFObject]
                            
                            for msg in unreadMessages {
                                msg.deleteInBackgroundWithBlock(nil)
                            }
                        }
                    }
                })
                
                self.navigationController?.pushViewController(messagesVC, animated: true)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func logout() {
        PFUser.logOut()
        
        self.navigationController?.popToRootViewControllerAnimated(true)
    }

    @IBAction func displaySettings(sender: AnyObject) {
        
        let settingsActionSheet = UIAlertController(title: "Settings", message: "Choose what you want to do", preferredStyle: .ActionSheet)
        settingsActionSheet.addAction(UIAlertAction(title: "Change Profille", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            let sb = UIStoryboard(name: "Main", bundle: nil)
            
            let profileVC = sb.instantiateViewControllerWithIdentifier("SignUpVC") as SignUpTableViewController
            profileVC.change = true
            
            self.navigationController?.pushViewController(profileVC, animated: true)
        }))
        settingsActionSheet.addAction(UIAlertAction(title: "Logout", style: UIAlertActionStyle.Default, handler: { (action:UIAlertAction!) -> Void in
            self.logout()
        }))
        settingsActionSheet.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(settingsActionSheet, animated: true, completion: nil)
    }
}
