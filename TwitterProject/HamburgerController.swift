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
  
  var menuOriginalCenter:CGPoint!
  var menuInView:CGPoint!
  var menuOutOfView:CGPoint!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor(twitterHex: "75B4FC")
    tableView.backgroundColor = UIColor.clearColor()
    
    setInitialContainerView()
    
    setTableView()
    
    setPanGestureRecognizer()
    
  }
  
  private func setTableView(){
    tableView.delegate =  self
    tableView.dataSource = self
    tableView.rowHeight = 100
    //tableView.estimatedRowHeight = 50
    tableView.tableFooterView = UIView()
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
    switch timelineType{
    case .Home:
      if(homeController == nil){
        homeController = initTimelineViewController(timelineType)
      }
      timelineController = homeController
    case .Mentions:
      if(mentionsController == nil){
        mentionsController = initTimelineViewController(timelineType)
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
    if menuInView == nil{
      menuInView = tableView.center
    }
    if menuOutOfView == nil{
      menuOutOfView = CGPoint(x: menuInView.x, y: menuInView.y - 320)
      tableView.center = menuOutOfView
    }
  }
  
  
  func openHamburgerMenu(sender: UIPanGestureRecognizer){
    setOriginalPoints()
    
    var point = sender.locationInView(view)
    var translation = sender.translationInView(view)
    var velocity = sender.velocityInView(view)

    
    switch(sender.state){
    case .Began:
      containerOriginalCenter = containerView.center
      menuOriginalCenter = tableView.center
      break;
    case .Changed:
      var x = containerOriginalCenter.x + translation.x
      var y = menuOriginalCenter.y + translation.x
      containerView.center = CGPoint(x: x, y: containerOriginalCenter.y)
      tableView.center = CGPoint(x: menuOriginalCenter.x, y: y)
      break;
    case .Ended:
      if velocity.x > 0{
        UIView.animateWithDuration(0.25, animations: { () -> Void in
          self.containerView.center = self.containerOutOfView
          self.tableView.center = self.menuInView
          self.view.layoutIfNeeded()
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
      self.tableView.center = self.menuOutOfView
      self.view.layoutIfNeeded()
      },
      completion: {(completed) -> Void in
        // TODO: Determine why table cell selections don't return the
        // tableview to the "out of view" position. This is a temp. hack
        // to get it to work.
       self.tableView.center = self.menuOutOfView
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = UITableViewCell()
    let backgroundView = UIView(frame:CGRect(x: 0,y: 0,width: 10,height: 10))
    backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
    cell.selectedBackgroundView = backgroundView
    cell.backgroundColor = UIColor.clearColor()
    cell.textLabel?.textColor = UIColor.whiteColor()
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
