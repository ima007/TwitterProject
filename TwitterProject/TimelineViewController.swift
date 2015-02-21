//
//  TimelineViewController.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/18/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

class TimelineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  let InfiniteScrollThreshold = 5
  
  var refreshControl:UIRefreshControl!
  
  @IBOutlet weak var tableView: UITableView!
  
  var account:Account?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    account = AccountManager.loggedInAccount
    
    let label = UILabel()
    label.text = "Home"
    label.textColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
    label.font = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
    navigationController?.navigationItem.titleView = label
    
    tableView.opaque = true
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    // Need to set estimated height to *something* to allow height Automatic Dimension
    // to take place.
    tableView.estimatedRowHeight = 100
    
    refreshControl = UIRefreshControl()
    refreshControl.attributedTitle = NSAttributedString(string: "Keep pulling!")
    refreshControl.addTarget(self, action: "addNewTweets:", forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
    
    //Load new data
    account?.getHomeTimeline({
      (tweets) -> Void in
        self.tableView.reloadData()
        self.tableView.opaque = false
      }, failure: {()-> Void in
        self.tableView.opaque = false
    })
  }
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
    return UITableViewAutomaticDimension
  }
  
  //Infinite scroll functionality, see older tweets
  func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
    if let count = account?.timeline?.count{
    if indexPath.row == count - InfiniteScrollThreshold {
        account?.getHomeTimeline(TimelineType.OlderTweets, success: {(tweets)->Void in
          self.tableView.reloadData()
          }, failure:{ () -> Void in })
      }
    }
  }
  
  //Pull to refresh, add new tweets
  func addNewTweets(sender:AnyObject){
    account?.getHomeTimeline(TimelineType.NewerTweets, success: {(tweets)->Void in
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
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return account?.timeline?.count ?? 0
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell") as! TweetCell
    
    if let tweet = account?.timeline?[indexPath.row]{
      cell.setContents(tweet)
    }
    
    return cell
  }
  
  
  
}
