//
//  LoginSignUpViewController.swift
//  CommunityChat
//
//  Created by Ziyang Tan on 2/20/15.
//  Copyright (c) 2015 Ziyang Tan. All rights reserved.
//

import UIKit

class LoginSignUpViewController: PFLogInViewController, PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.signUpController.delegate = self
        
        self.logInView.logo = UIImageView(image: UIImage(named: "logo"))
        self.signUpController.signUpView.logo = UIImageView(image: UIImage(named: "logo"))
        
        self.logInView.logo.contentMode = .Center
        self.signUpController.signUpView.logo.contentMode = .Center
        
        if PFUser.currentUser() != nil {
            showChatOverView()
        }
    }
    
    func logInViewController(logInController: PFLogInViewController!, didLogInUser user: PFUser!) {
        showChatOverView()
    }
    
    func signUpViewController(signUpController: PFSignUpViewController!, didSignUpUser user: PFUser!) {
        signUpController.dismissViewControllerAnimated(true, completion: { () -> Void in
            self.showChatOverView()
        })
    }
    
    func showChatOverView() {
        
        let sb = UIStoryboard(name:"Main", bundle: nil)
        
        let overviewVC = sb.instantiateViewControllerWithIdentifier("ChatOverviewVC") as OverviewTableViewController
        
        overviewVC.navigationItem.setHidesBackButton(true, animated: false)
        
        self.navigationController?.pushViewController(overviewVC, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
   
}
