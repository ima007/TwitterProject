//
//  TimelineViewController.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/18/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

protocol TimelineViewDelegate{
  func update()
}

class TimelineViewController: TweetActionsController {
  
  let InfiniteScrollThreshold = 5
  
  var refreshControl:UIRefreshControl!
  
  @IBOutlet weak var tableView: UITableView!
  
  var timelineType:TimelineType?
  var screen_name:String?
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    println("timeline view did appear")
    setNavTitle()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    println("timeline view did load")
    
    setTableView()
    
    delegate = self
    
    setToCurrentAccount()
    setRefreshControl()
    loadInitialData()
    setNavTitle()
    
  }
  
  func setTableView(){
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    // Need to set estimated height to *something* to allow height Automatic Dimension
    // to take place.
    tableView.estimatedRowHeight = 100

  }
  
  func setToCurrentAccount(){
     account = AccountManager.loggedInAccount
  }
  
  func setNavTitle(){
    println("timeline view setNavTitle")
    //var label = UILabel()
    //TODO: More robust handling for timeline types
    //label.text = timelineType == .Mentions ? "Mentions" : "Home"
    //label.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    //label.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
    //navigationController?.navigationItem.titleView = label
    navigationController?.navigationBar.topItem?.title = timelineType == .Mentions ? "Mentions" : "Home"
  

  }
  
  func loadInitialData(){
    //Load new data
    if(timelineType == nil){
      timelineType = TimelineType.Home
    }
    account?.getTimeline(timelineType, direction: TimelineDirection.AllTweets, screen_name: screen_name, success:{
      (tweets) -> Void in
      self.tableView.reloadData()
      },
      failure: {()-> Void in
        println("failed to load initial data")
    })
  }
  
  func setRefreshControl(){
    refreshControl = UIRefreshControl()
    refreshControl.attributedTitle = NSAttributedString(string: "Keep pulling!")
    refreshControl.addTarget(self, action: "addNewTweets:", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
  }
  

  
  //Pull to refresh, add new tweets
  func addNewTweets(sender:AnyObject){
    account?.getTimeline(timelineType, direction: TimelineDirection.NewerTweets, success: {(tweets)->Void in
      self.tableView.reloadData()
      self.refreshControl.endRefreshing()
      }, failure:{ () -> Void in
      self.refreshControl.endRefreshing()
    })
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  @IBAction func onSignout(sender: AnyObject) {
     AccountManager.sharedInstance.logoutCurrentAccount()
  }
  
  
  @IBAction func onCompose(sender: AnyObject) {
    
    let newStoryboard : UIStoryboard = UIStoryboard(name: "Compose", bundle: nil)
    var composeController: ComposeController = newStoryboard.instantiateViewControllerWithIdentifier("ComposeController") as! ComposeController
    composeController.delegate = self
    composeController.account = account
    
    let navigationController = UINavigationController(rootViewController: composeController)
    
    self.presentViewController(navigationController, animated: true, completion: nil)

  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "seeDetailSegue"{
      if let destinationVC = segue.destinationViewController as? TweetViewController{
        if let tweetIndex = tableView.indexPathForSelectedRow()?.row {
          destinationVC.tweet = account?.timeline?[tweetIndex]
          destinationVC.account = account
          destinationVC.delegate = self
        }
      }
    }
  }
  
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension TimelineViewController:UITableViewDataSource, UITableViewDelegate{
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
    return UITableViewAutomaticDimension
  }
  
  //Infinite scroll functionality, see older tweets
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
    if let count = account?.timeline?.count{
      if indexPath.row == count - InfiniteScrollThreshold {
        account?.getTimeline(timelineType, direction: TimelineDirection.OlderTweets, success: {(tweets)->Void in
          self.tableView.reloadData()
          }, failure:{ () -> Void in })
      }
    }
  }
 
  private func getTimeline() -> [Tweet]?{
    var timeline = account?.timeline
    
    if let timelineType = timelineType{
      switch timelineType{
      case .Home:
        timeline = account?.timeline
      case .Mentions:
        timeline = account?.mentions
      default:
        break
      }
    }
    return timeline
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return getTimeline()?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
    
    var timeline = getTimeline()
    
    if let tweet = timeline?[indexPath.row]{
      cell.setContents(tweet)
      cell.account = account
      cell.delegate = self
      tweet.delegate = cell
    }
    
    return cell
  }
  
}

extension TimelineViewController:TimelineViewDelegate{
  func update(){
    println("Timeline updated!")
    tableView.reloadData()
  }
}


