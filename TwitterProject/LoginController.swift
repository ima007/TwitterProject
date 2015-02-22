//
//  ViewController.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/16/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

class LoginController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    title = "TwitterProject"
    
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func loginPressed(sender: AnyObject) {
    
    if let account = AccountManager.loggedInAccount {
      let newStoryboard = UIStoryboard(name: "Timeline", bundle: nil)
      var timelineController = newStoryboard.instantiateViewControllerWithIdentifier("TimelineViewController") as! TimelineViewController

      timelineController.account = AccountManager.loggedInAccount
      
      let newNavigationController = UINavigationController(rootViewController: timelineController)
      
      self.presentViewController(newNavigationController, animated: true, completion: nil)
    }else{
      AccountManager.sharedInstance.loginNewAccount()
    }
  }

}

