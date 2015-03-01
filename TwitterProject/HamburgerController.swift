//
//  HamburgerController.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/26/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

enum PageType{
  case Profile
}

class HamburgerController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var tableView: UITableView!
  
  private let initialContainerStoryboard = UIStoryboard(name: "Timeline", bundle: nil)
  private var containerChildView: UIView!
  private var containerChildNavController: UINavigationController?
  
  private var homeController:UINavigationController!
  private var mentionsController:UINavigationController!
  private var profileViewController: UINavigationController!
  private var selectedMenuItem:Int = 0
  
  var account:Account?
  
  
  private let sides:[NSLayoutAttribute] = [.Left,.Bottom,.Width,.Height]
  
  var containerOriginalCenter: CGPoint!
  var containerInView: CGPoint!
  var containerOutOfView: CGPoint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    println("loaded!")
    
    setInitialContainerView()
    
    setTableView()
    
    setPanGestureRecognizer()
    
  }
  
  private func setTableView(){
    tableView.delegate =  self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 50
  }
  
  private func setPanGestureRecognizer(){
    var panRecognizer = UIPanGestureRecognizer(target: self, action: "openHamburgerMenu:")
    view.addGestureRecognizer(panRecognizer)
  }
  
  private func setInitialContainerView(){
    containerChildNavController = initialContainerStoryboard.instantiateInitialViewController() as? UINavigationController
    
    if let containerChildNavController = containerChildNavController{
      addChildViewController(containerChildNavController)
      
      containerChildNavController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
      
      //Add view and controller.
      containerView.insertSubview(containerChildNavController.view, atIndex: 0)
      containerView.addConstraints(getContainerLayoutConstraintsFor(containerChildNavController.view))
    
      containerChildNavController.didMoveToParentViewController(self)
      
      homeController = containerChildNavController
      

      
    }else{
      println("wow, catastrophic error...")
    }
  }
  
  private func addActiveChildViewController(childController:UINavigationController?){
    containerChildNavController = childController
    if let containerChildNavController = containerChildNavController{
      addChildViewController(containerChildNavController)
      containerChildNavController.view.setTranslatesAutoresizingMaskIntoConstraints(false)
      //Add view and controller.
      containerView.insertSubview(containerChildNavController.view, atIndex: 0)
      containerView.addConstraints(getContainerLayoutConstraintsFor(containerChildNavController.view))
      containerChildNavController.didMoveToParentViewController(self)
    }else{
      println("no child")
    }
  }
  
  private func removeActiveChildViewController(){
    containerChildNavController?.willMoveToParentViewController(self)
    containerChildNavController?.view.removeFromSuperview()
    containerChildNavController?.removeFromParentViewController()
  }
  
  private func initTimelineViewController(timelineType: TimelineType) -> UINavigationController?{
    let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
    let timelineController = storyboard.instantiateViewControllerWithIdentifier("TimelineViewController") as! TimelineViewController
    
    timelineController.timelineType = timelineType
    var navigationController = UINavigationController(rootViewController: timelineController)

    return navigationController
  }
  
  private func initProfileViewController() -> UINavigationController?{
    let storyboard = UIStoryboard(name: "Timeline", bundle: nil)
    let profileController = storyboard.instantiateViewControllerWithIdentifier("ProfileViewController") as! ProfileViewController
    profileController.account = account
    profileController.viewAccount = account
    var navigationController = UINavigationController(rootViewController: profileController)
    
    return navigationController
  }
  
  private func updateContainerViewTo(timelineType: TimelineType){
    var timelineController: UINavigationController?
    var newController = false
    switch timelineType{
    case .Home:
      if(homeController == nil){
        homeController = initTimelineViewController(timelineType)
        //newController = true
      }
      timelineController = homeController
    case .Mentions:
      if(mentionsController == nil){
        mentionsController = initTimelineViewController(timelineType)
        //newController = true
      }
      timelineController = mentionsController
    default:
      println("updateContainerViewTo: error ||| timeline controller not found!")
        break;
    }
    removeActiveChildViewController()
    addActiveChildViewController(timelineController)
  }
  
  private func updateContainerViewTo(pageType: PageType){
    var profileController: UINavigationController?
    switch pageType{
    case .Profile:
      if profileViewController == nil {
        profileViewController = initProfileViewController()
      }
      profileController = profileViewController
    default:
      break;
    }
    removeActiveChildViewController()
    addActiveChildViewController(profileController)

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
    return NSLayoutConstraint(item: item, attribute: attribute, relatedBy: .Equal, toItem: containerView, attribute: attribute, multiplier: 1.0, constant: 0.0)
  }
  
  private func setOriginalPoints(){
    if containerInView == nil{
      containerInView = containerView.center
    }
    if containerOutOfView == nil{
      containerOutOfView = CGPoint(x: containerInView.x + containerView.frame.width - 40, y:containerInView.y)
    }
  }
  
  func openHamburgerMenuViaRotation(sender: UIRotationGestureRecognizer){
    var point = sender.locationInView(view)
    var rotation = sender.rotation
    var velocity = sender.velocity
    
    containerView.transform = CGAffineTransformRotate(containerView.transform, rotation);
    sender.rotation = 0.0;
  }
  
  func openHamburgerMenu(sender: UIPanGestureRecognizer){
    setOriginalPoints()
    
    var point = sender.locationInView(view)
    var translation = sender.translationInView(view)
    var velocity = sender.velocityInView(view)

    
    switch(sender.state){
    case .Began:
      containerOriginalCenter = containerView.center
      break;
    case .Changed:
      var x = containerOriginalCenter.x + translation.x
      containerView.center = CGPoint(x: x, y: containerOriginalCenter.y)
      break;
    case .Ended:
      if velocity.x > 0{
        UIView.animateWithDuration(0.25, animations: { () -> Void in
          self.containerView.center = self.containerOutOfView
        })
      }else if velocity.x < 0 {
        showContainer()
      }
      break;
    default:
      break;
    }
  }
  
  private func showContainer(){
    UIView.animateWithDuration(0.25, animations: { () -> Void in
      self.containerView.center = self.containerInView
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    switch indexPath.row{
    case 0:
      cell.textLabel?.text = "Home"
    case 1:
      cell.textLabel?.text = "Profile"
    case 2:
      cell.textLabel?.text = "Mentions"
    default:
      break;
    }
    return cell
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    switch indexPath.row{
    case 0:
      if selectedMenuItem != 0{
        updateContainerViewTo(TimelineType.Home)
        selectedMenuItem = 0
      }
    case 1:
      if selectedMenuItem != 1{
        updateContainerViewTo(PageType.Profile)
        selectedMenuItem = 1
      }
    case 2:
      if selectedMenuItem != 2{
        updateContainerViewTo(TimelineType.Mentions)
        selectedMenuItem = 2
      }
    default:
      break;
    }
    showContainer()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3;
  }
  
  func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
    return true
  }

}
