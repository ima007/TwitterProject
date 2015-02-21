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
    
    // Do any additional setup after loading the view, typically from a nib.
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func loginPressed(sender: AnyObject) {
    
    if let account = AccountManager.loggedInAccount {
      let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
      let controller = storyboard.instantiateInitialViewController() as! TimelineViewController
      
      controller.account = account
      
      navigationController?.pushViewController(controller, animated: true)
    }else{
      AccountManager.sharedInstance.loginNewAccount()
    }
  }

}

