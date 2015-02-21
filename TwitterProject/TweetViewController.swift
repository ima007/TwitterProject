//
//  TweetViewController.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

class TweetViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  var tweet:Tweet?
  
  @IBOutlet weak var tableView: UITableView!
  
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.delegate = self
    tableView.dataSource = self
    tableView.rowHeight = UITableViewAutomaticDimension
    // Need to set estimated height to *something* to allow height Automatic Dimension
    // to take place.
    tableView.estimatedRowHeight = 100
    

  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }
  
  func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat{
    return UITableViewAutomaticDimension
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var returnCell = UITableViewCell()
    switch indexPath.row{
    case 0:
      if let cell = tableView.dequeueReusableCellWithIdentifier("TweetDetailCell") as? TweetDetailCell{
        cell.setContent(tweet)
        returnCell = cell
      }
    case 1:
      if let cell = tableView.dequeueReusableCellWithIdentifier("TweetStatsCell") as? TweetStatsCell{
        cell.setContent(tweet)
        returnCell = cell
      }
    case 2:
      if let cell = tableView.dequeueReusableCellWithIdentifier("TweetActionsCell") as? TweetActionsCell{
        returnCell = cell
      }
    default:
      break;
    }

    return returnCell
  }
  
}
