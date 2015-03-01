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

protocol TimelineScrollDelegate{
  func scrollingUp(scrollView:UIScrollView)
  func scrollingDown(scrollView:UIScrollView)
  func scrollDidEndDecelerating(scrollView:UIScrollView)
  func scrollWillBeginDecelerating(scrollView:UIScrollView)
  func endRefreshing()
}

class TimelineViewController: TweetActionsController {
  
  let InfiniteScrollThreshold = 5
  
  var refreshControl:UIRefreshControl!
  var scrollDelegate:TimelineScrollDelegate?
  
  var lastContentOffset:CGFloat = 0
  
  @IBOutlet weak var tableView: UITableView!
  
  var timelineType:TimelineType?
  var screen_name:String?
  
  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    println("timeline view did appear")
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
    title = timelineType == .Mentions ? "Mentions" : "Home"
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
      self.scrollDelegate?.endRefreshing()
      }, failure:{ () -> Void in
      self.refreshControl.endRefreshing()
      self.scrollDelegate?.endRefreshing()
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
          destinationVC.tweet = getTimeline()?[tweetIndex]
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
    if let count = getTimeline()?.count{
      if indexPath.row == count - InfiniteScrollThreshold {
        account?.getTimeline(timelineType, direction: TimelineDirection.OlderTweets, screen_name: screen_name, success: {(tweets)->Void in
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
      case .User:
        if let userTimeline = account?.userTimelines[screen_name!]{
          timeline = userTimeline
        }else{
          println("sorry dude \(screen_name)")
        }
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
  

  func scrollViewDidScroll(scrollView: UIScrollView) {
    if lastContentOffset > scrollView.contentOffset.y{
      scrollDelegate?.scrollingUp(scrollView)
    } else if lastContentOffset < scrollView.contentOffset.y{
      scrollDelegate?.scrollingDown(scrollView)
    }
    lastContentOffset = scrollView.contentOffset.y;
  }
  
  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    scrollDelegate?.scrollDidEndDecelerating(scrollView)
  }
  
  func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
    scrollDelegate?.scrollWillBeginDecelerating(scrollView)
  }
  
}

extension TimelineViewController:TimelineViewDelegate{
  func update(){
    println("Timeline updated!")
    tableView.reloadData()
  }
}


