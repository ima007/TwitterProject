//
//  TweetActionsController.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/22/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

class TweetActionsController: UIViewController, TweetActionsDelegate, ComposeModalDelegate {
  
  var account: Account?
  var delegate: TimelineViewDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  
  func reply(tweet: Tweet?) {
    let newStoryboard : UIStoryboard = UIStoryboard(name: "Compose", bundle: nil)
    var composeController = newStoryboard.instantiateViewControllerWithIdentifier("ComposeController") as! ComposeController
    composeController.delegate = self
    composeController.account = account
    composeController.tweet = tweet
    
    let navigationController = UINavigationController(rootViewController: composeController)
    
    self.presentViewController(navigationController, animated: true, completion: nil)
  }
  func favorite(tweet: Tweet?) {
    account?.favorite(tweet, success: success, failure: {() -> Void in})
  }
  func unfavorite(tweet: Tweet?) {
    account?.unfavorite(tweet, success: success, failure: {() -> Void in})
  }
  func retweet(tweet: Tweet?) {
    account?.retweet(tweet, success: success, failure: {() -> Void in})
  }
  func unretweet(tweet: Tweet?){
    account?.unretweet(tweet, success: success, failure: {() -> Void in})
  }
  
  //Propagate that a tweet action was successful
  func success(tweet: Tweet?){
    delegate?.update()
  }
  
  func dismissed(composeController:ComposeController) {
    composeController.dismissViewControllerAnimated(true, completion: nil)
  }
  func sent(composeController: ComposeController, newTweet: Tweet?) {
    if let newTweet = newTweet{
      account?.timeline?.insert(newTweet, atIndex: 0)
      delegate?.update()
    }
    composeController.dismissViewControllerAnimated(true, completion: nil)
  }
  
}



