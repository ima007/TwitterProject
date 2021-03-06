//
//  TwitterClient.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/16/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import Foundation

enum TimelineType{
  case Home
  case Mentions
  case User
}

enum TimelineDirection{
  case OlderTweets
  case NewerTweets
  case AllTweets
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
          if let account = account{
            AccountManager.loggedInAccount = account
            NSNotificationCenter.defaultCenter().postNotificationName(accountDidLoginNotification, object: nil)
          }
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
  
  func getTimeline(timelineType: String, params:[String:AnyObject]?, success:([Tweet]? -> Void), failure:()->Void){
    println("1.1/statuses/\(timelineType)_timeline.json")
    GET("1.1/statuses/\(timelineType)_timeline.json",
      parameters: params ?? nil,
      success:{
        (operation, response) -> Void in
        var tweets:[Tweet]?
        tweets <<<<* response
        success(tweets)
      },
      failure: {
        (operation, error) -> Void in
        println("\(timelineType) timleine error |||| \(error)")
        failure()
    })
  }
  
  //screen_name
  func getUserTimeline(#params:[String:AnyObject]?,success:([Tweet]? -> Void), failure:()->Void){
    getTimeline("user", params: params, success: success, failure: failure)
  }
  
  func getMentionsTimeline(#params:[String:AnyObject]?,success:([Tweet]? -> Void), failure:()->Void){
    getTimeline("mentions", params: params, success: success, failure: failure)

  }
  
  func getHomeTimeline(#params:[String:AnyObject]?,success:([Tweet]? -> Void), failure:()->Void){
    getTimeline("home", params: params, success: success, failure: failure)
  }
  
  //status
  //in_reply_to_status_id
  func sendTweet(#params:[String:AnyObject]?, success: (Tweet? -> Void), failure:() -> Void){
    POST("1.1/statuses/update.json",
      parameters: params ?? nil,
      success:{
        (operation, response) -> Void in
        var tweet:Tweet?
        //println("\(response)")
        tweet <<<< response
        success(tweet)
      },
      failure: {
        (operation, error) -> Void in
        println("sendTweet error |||| \(error)")
        failure()
    })
  }
  
  func retweet(tweet:Tweet?, success: (Tweet? -> Void), failure:() -> Void){
    if let tweetId = tweet?.id_str{
      retweet(tweetId, success: { (retweetedTweet) -> Void in
        tweet?.current_user_retweet = retweetedTweet?.id_str
        success(retweetedTweet)
      },
      failure: failure)
    }
  }
  
  func retweet(tweetId:String?, success: (Tweet? -> Void), failure:() -> Void){
    if let tweetId = tweetId{
      POST("1.1/statuses/retweet/" + tweetId + ".json",
        parameters: nil,
        success:{
          (operation, response) -> Void in
          var tweet:Tweet?
          println("\(response)")
          tweet <<<< response
          success(tweet)
        },
        failure: {
          (operation, error) -> Void in
          println("retweet error |||| \(error)")
          failure()
      })
    }
  }
  
  func favorite(tweetId:String?, success: (Tweet? -> Void), failure:() -> Void){
    var params = [String:AnyObject]()
    if let tweetId = tweetId{
      params["id"] = tweetId
    }
    POST("1.1/favorites/create.json",
      parameters: params,
      success:{
        (operation, response) -> Void in
        var tweet:Tweet?
        //println("\(response)")
        tweet <<<< response
        success(tweet)
      },
      failure: {
        (operation, error) -> Void in
        println("favorite error |||| \(error)")
        failure()
    })
  }
  
  func unfavorite(tweetId:String?, success: (Tweet? -> Void), failure:() -> Void){
    var params = [String:AnyObject]()
    if let tweetId = tweetId{
      params["id"] = tweetId
    }
    POST("1.1/favorites/destroy.json",
      parameters: params,
      success:{
        (operation, response) -> Void in
        var tweet:Tweet?
        //println("\(response)")
        tweet <<<< response
        success(tweet)
      },
      failure: {
        (operation, error) -> Void in
        println("unfavorite error |||| \(error)")
        failure()
    })
  }
  
  func deleteTweet(tweetId:String?, success: (Tweet? -> Void), failure:() -> Void){
    if let tweetId = tweetId{
    POST("1.1/statuses/destroy/" + tweetId + ".json",
      parameters: nil,
      success:{
        (operation, response) -> Void in
        var tweet:Tweet?
        //println("\(response)")
        tweet <<<< response
        success(tweet)
      },
      failure: {
        (operation, error) -> Void in
        println("delete error |||| \(error)")
        failure()
    })
    }
  }
  
  func unretweet(tweetId:String?, success: (Tweet? -> Void), failure:() -> Void){
    var params = [String:AnyObject]()
    if let tweetId = tweetId{
      params["id"] = tweetId
    }
    params["include_my_retweet"] = 1
    GET("1.1/statuses/show.json",
      parameters: params,
      success:{
        (operation, response) -> Void in
        var tweet:Tweet?
        println("\(response)")
        tweet <<<< response
        if let retweetId = tweet?.current_user_retweet{
          println("\(retweetId)")
          self.deleteTweet(retweetId, success: success, failure: failure)
        }else{
          println("unretweet error |||| could not unwrap tweet from statuses/show.json")
          failure()
        }
      },
      failure: {
        (operation, error) -> Void in
        println("unretweet error w/ \(params)")
        println("\(error)")
        failure()
    })
  }
  
  func unretweet(tweet:Tweet?, success: (Tweet? -> Void), failure:() -> Void){
    if let tweet = tweet, let isRetweeted = tweet.retweeted{
      if isRetweeted{
        if let retweetId = tweet.current_user_retweet{
          deleteTweet(retweetId, success: success, failure: failure)
        }else{
          unretweet(tweet.id_str, success: success, failure: failure)
        }
      }
    }
  }


}
