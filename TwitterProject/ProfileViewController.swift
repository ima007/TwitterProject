//
//  ProfileViewController.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/28/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

class ProfileViewController: TweetActionsController, TimelineScrollDelegate, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var profileHeaderContainer: UIView!
  
  @IBOutlet weak var backgroundImage: UIImageView!
  
  @IBOutlet weak var avatarImage: UIImageView!
  
  @IBOutlet weak var nameLabel: UILabel!
  
  @IBOutlet weak var screenNameLabel: UILabel!
  
  @IBOutlet weak var tweetNumber: UILabel!
  
  @IBOutlet weak var followingNumber: UILabel!
  
  @IBOutlet weak var followersNumber: UILabel!
  
  var viewAccount:Account?
  private var timelineController:TimelineViewController!
  private var profileHeaderCenter:CGPoint!
  private var imageSize:CGSize!
  
  private let scrollBounceFactor:CGFloat = 1.3
  private let profileContainerHeaderHeight:CGFloat = 190
  
  private let sides:[NSLayoutAttribute] = [.Left,.Bottom,.Width,.Height]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setTitleText()
    
    let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
    timelineController = storyboard.instantiateViewControllerWithIdentifier("TimelineViewController") as! TimelineViewController
    timelineController.timelineType = .User
    timelineController.screen_name = viewAccount?.screen_name
    
    addChildViewController(timelineController)
    view.insertSubview(timelineController.view, atIndex: 0)
    //timelineController.tableView.tableHeaderView = profileHeaderContainer
    view.addConstraints(getContainerLayoutConstraintsFor(timelineController.view))
    timelineController.tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 200))
    
    avatarImage.setImageWithURL(viewAccount?.profileImageNsUrl)
    backgroundImage.setImageWithURL(viewAccount?.profielBackgroudnImageNsUrl)
    backgroundImage.alpha = 0.4
    nameLabel.text = viewAccount?.name
    nameLabel.textColor = viewAccount?.profileTextColor
    println("\(viewAccount?.profileTextColor)")
    screenNameLabel.text = viewAccount?.screenNameWithAt
    screenNameLabel.textColor = viewAccount?.profileTextColor
    tweetNumber.text = viewAccount?.statuses_count?.abbreviateNumber()
    followersNumber.text = viewAccount?.followers_count?.abbreviateNumber()
    followingNumber.text = viewAccount?.friends_count?.abbreviateNumber()
    profileHeaderContainer.sendSubviewToBack(backgroundImage)
    
    profileHeaderContainer.setNeedsLayout()
    profileHeaderContainer.layoutIfNeeded()
    
    profileHeaderContainer.frame.size.height = profileContainerHeaderHeight

    view.addConstraints([
      NSLayoutConstraint(item: profileHeaderContainer, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: profileHeaderContainer, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1.0, constant: 0.0),
      NSLayoutConstraint(item: profileHeaderContainer, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1.0, constant: 60.0)
      ])

    timelineController.scrollDelegate = self
    
    timelineController.didMoveToParentViewController(self)
    
    profileHeaderCenter = profileHeaderContainer.center
    
    var panRecognizer = UIPanGestureRecognizer(target: self, action: "panGesture:")
    view.addGestureRecognizer(panRecognizer)
    panRecognizer.delegate = self
    
    imageSize = backgroundImage.frame.size
    
    
  }

  func panGesture(sender: UIPanGestureRecognizer){
    var point = sender.locationInView(view)
    var translation = sender.translationInView(view)
    var velocity = sender.velocityInView(view)
    
    
    switch(sender.state){
    case .Changed:
      if velocity.y > 0{
        backgroundImage.transform = CGAffineTransformScale(backgroundImage.transform, 1.01, 1.01);
      }else if velocity.y < 0{
        UIView.animateWithDuration(0.25, animations: { () -> Void in
          self.backgroundImage.transform = CGAffineTransformIdentity
        })
      }
      break;
    case .Ended:
      UIView.animateWithDuration(0.25, animations: { () -> Void in
        self.backgroundImage.transform = CGAffineTransformIdentity
      })
      break;
    default:
      break;
    }

  }
  
  func scrollingDown(scrollView:UIScrollView) {

    self.profileHeaderContainer.center = CGPoint(x: self.profileHeaderContainer.center.x, y: self.profileHeaderCenter.y - self.profileContainerHeaderHeight/2 - (scrollView.contentOffset.y*self.scrollBounceFactor) )
    

    UIView.animateWithDuration(0.5, animations: { () -> Void in
      
      self.profileHeaderContainer.alpha = 0.5
    })

  }
  
  func scrollingUp(scrollView:UIScrollView) {
    
    self.profileHeaderContainer.center = CGPoint(x: self.profileHeaderContainer.center.x, y: self.profileHeaderCenter.y - self.profileContainerHeaderHeight/2 - (scrollView.contentOffset.y*self.scrollBounceFactor) )
    UIView.animateWithDuration(0.5, animations: { () -> Void in
     
      self.profileHeaderContainer.alpha = 1.0
    })
  }
  
  func endRefreshing() {
    UIView.animateWithDuration(0.5, animations: { () -> Void in
      self.profileHeaderContainer.alpha = 1.0
    })
  }
  
  func scrollDidEndDecelerating(scrollView: UIScrollView) {
    UIView.animateWithDuration(0.25, animations: { () -> Void in
      
      self.profileHeaderContainer.alpha = 1.0
    })
  }
  
  func scrollWillBeginDecelerating(scrollView: UIScrollView) {
    
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
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
    return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .Equal, toItem: view, attribute: attribute, multiplier: 1.0, constant: 0.0)
  }
  
  
}
