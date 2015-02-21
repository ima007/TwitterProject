//
//  ComposeController.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

protocol ComposeModalDelegate{
  func dismissed(controller:ComposeController)
}

class ComposeController: UIViewController {
  
  @IBOutlet weak var tweetInput: UITextView!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var profileName: UILabel!
  
  @IBOutlet weak var profileScreenName: UILabel!
  
  var delegate: ComposeModalDelegate?
  var account: Account?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    profileImage.twi_setImageWithUrl(account?.profileImageNsUrl)
    profileName.text = account?.name
    profileScreenName.text = account?.screenNameWithAt
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func tappedCancelButton(sender: AnyObject) {
    delegate?.dismissed(self)
  }
  

  @IBAction func tappedSendButton(sender: AnyObject) {
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
