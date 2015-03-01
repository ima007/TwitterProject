//
//  ProfileViewController.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

class ProfileViewController: TweetActionsController {
  
  @IBOutlet weak var profileTweetsContainer: UIView!
  var viewAccount:Account?
  
  private let sides:[NSLayoutAttribute] = [.Left,.Bottom,.Width,.Height]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setTitleText()
    
    let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
    var tweetsController = storyboard.instantiateViewControllerWithIdentifier("TimelineViewController") as! TimelineViewController
    tweetsController.timelineType = .User
    tweetsController.screen_name = viewAccount?.screen_name
    
    addChildViewController(tweetsController)
    profileTweetsContainer.insertSubview(tweetsController.view, atIndex: 0)
    profileTweetsContainer.addConstraints(getContainerLayoutConstraintsFor(tweetsController.view))
    
    tweetsController.didMoveToParentViewController(self)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  private func setTitleText(){
    println("\(viewAccount)")
    if viewAccount?.screen_name == account?.screen_name{
      title = "Me"
    }else{
      title = viewAccount?.screen_name
    }
  }
  
  /**
  * Makes the child view to the containerView equal to its parent's width/height
  */
  private func getContainerLayoutConstraintsFor(item: UIView) -> [NSLayoutConstraint]{
    var array = [NSLayoutConstraint]()
    for side in sides{
      array.append(getContainerLayoutConstraintFor(item, attribute: side))
    }
    return array
  }
  
  private func getContainerLayoutConstraintFor(item: UIView, attribute:NSLayoutAttribute) -> NSLayoutConstraint{
    return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .Equal, toItem: profileTweetsContainer, attribute: attribute, multiplier: 1.0, constant: 0.0)
  }
  
  
}
