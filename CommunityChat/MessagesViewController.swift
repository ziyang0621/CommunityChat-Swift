//
//  MessagesViewController.swift
//  CommunityChat
//
//  Created by Ziyang Tan on 2/20/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class MessagesViewController: JSQMessagesViewController {
    
    var room:PFObject!
    var incomingUser:PFUser!
    var users = [PFUser]()
    
    var message = [JSQMessage]()
    var messageObjects = [PFObject]()
    
    var outgoingBubbleImage = JSQMessagesBubbleImage()
    var incomingBubbleImage = JSQMessagesBubbleImage()
    
    var selfAvatar = JSQMessagesAvatarImage()
    var incomingAvatar = JSQMessagesAvatarImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Messages"
        self.senderId = PFUser.currentUser().objectId
        self.senderDisplayName = PFUser.currentUser().username
        
        let selfUsername = PFUser.currentUser().username as NSString
        let incomingUsername = incomingUser.username as NSString
        
        selfAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(selfUsername.substringWithRange(NSMakeRange(0, 2)), backgroundColor: UIColor.blackColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        
        incomingAvatar = JSQMessagesAvatarImageFactory.avatarImageWithUserInitials(incomingUsername.substringWithRange(NSMakeRange(0, 2)), backgroundColor: UIColor.blackColor(), textColor: UIColor.whiteColor(), font: UIFont.systemFontOfSize(14), diameter: UInt(kJSQMessagesCollectionViewAvatarSizeDefault))
        
        let bubbleFactory = JSQMessagesBubbleImageFactory()
        
        outgoingBubbleImage = bubbleFactory.outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
        incomingBubbleImage = bubbleFactory.incomingMessagesBubbleImageWithColor(UIColor.grayColor())

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
