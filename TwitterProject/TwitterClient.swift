//
//  TwitterClient.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/16/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import Foundation

enum TimelineType{
  case OlderTweets
  case NewerTweets
}

class TwitterClient: BDBOAuth1RequestOperationManager {
  
  private let Bundle = NSBundle.mainBundle()
  private let BaseUrl = "https://api.twitter.com"
  
  private var account:Account?
  
  init(account: Account){
    self.account = account
    
    let consumerKey = NSBundle.mainBundle().objectForInfoDictionaryKey("TWEET_CONSUMER_KEY") as! String
    let consumerSecret = NSBundle.mainBundle().objectForInfoDictionaryKey("TWEET_CONSUMER_SECRET") as! String
    
    super.init(baseURL: NSURL(string:BaseUrl),
      consumerKey: consumerKey,
      consumerSecret: consumerSecret)
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder:aDecoder)
  }
  
  func getRequestToken(){
    requestSerializer.removeAccessToken()
    fetchRequestTokenWithPath("oauth/request_token",
      method: "GET",
      callbackURL: NSURL(string:"twitterproject://oauth"),
      scope: nil,
      success: {(requestToken) -> Void in
        println("got the request token!")
        let authUrl = "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)"
        UIApplication.sharedApplication().openURL(NSURL(string:authUrl)!);
      },
      failure: {(requestTokenError) -> Void in
        println("failed! \(requestTokenError)")
    })
  }
  
  func getAccessToken(queryString:String){
    fetchAccessTokenWithPath("oauth/access_token",
      method: "POST",
      requestToken: BDBOAuth1Credential(queryString: queryString),
      success: {(accessToken) -> Void in
        println("got access token success!")
        
        self.requestSerializer.saveAccessToken(accessToken)
        
        self.getAccount({(account) -> Void in
          AccountManager.loggedInAccount = account
          NSNotificationCenter.defaultCenter().postNotificationName(accountDidLoginNotification, object: nil)

        },
          failure:{() -> Void in
        })
      },
      failure: {(tokenError) -> Void in
        println("failed! \(tokenError)")
    })
  }
  

  
  func getAccount(success:(Account? -> Void), failure:()->Void){
    GET("1.1/account/verify_credentials.json",
      parameters: nil,
      success:{
        (operation, response) -> Void in
        var account:Account?
        account <<<< response
        success(account)
      },
      failure: {
        (operation, error) -> Void in
    })
  }
  
  func getHomeTimeline(success:([Tweet]? -> Void), failure:()->Void){
    getHomeTimeline(params: nil, success: success, failure: failure)
  }
  
  func getHomeTimeline(#params:[String:AnyObject]?,success:([Tweet]? -> Void), failure:()->Void){
    GET("1.1/statuses/home_timeline.json",
      parameters: params ?? nil,
      success:{
        (operation, response) -> Void in
        var tweets:[Tweet]?
        println("\(response)")
        tweets <<<<* response
        success(tweets)
      },
      failure: {
        (operation, error) -> Void in
        failure()
    })
  }
  
  /*
  
  Social.frameowkr
  Accounts.framework instead of normal oauth
  
  storyboard = UIStoryBoard(instance
  storyboard.instantiateInitialViewController() as modalviewthing
  self.parentViewController
  
  How to dismiss?
  implement delegate/protocol on modalviewcontroller, and implement whatever dimiss
  you want on your main controller
  */
  
  func getTimeline(count: Int, success: ((tweets: [Tweet])->Void), failure: ((operation: AFHTTPRequestOperation, err: NSError)->Void)) {
    
    self.GET("statuses/home_timeline.json?count=20", parameters: nil,
      success: {
        (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
        
        var tweets: [Tweet] = [Tweet]()
        let tweetsDictionaryArray: Array<Dictionary<String,AnyObject>> = response as! Array<Dictionary<String,AnyObject>>;
        for tweet in tweetsDictionaryArray {
          //tweets.append(Tweet.fromJsonTweet(tweet));
        }
        
        success(tweets: tweets)
        
      }, failure: {
        (operation: AFHTTPRequestOperation!, err: NSError!) -> Void in
        
        failure(operation: operation, err: err);
      }
    )
  }
}