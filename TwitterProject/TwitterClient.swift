//
//  TwitterClient.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/16/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import Foundation

class TwitterClient: BDBOAuth1RequestOperationManager {
  
  //Singleton
  class var sharedInstance: TwitterClient {
    struct Static {
      static let instance:TwitterClient = TwitterClient()
    }
    return Static.instance
  }
  
  private let Bundle = NSBundle.mainBundle()
  private let BaseUrl = "https://api.twitter.com"
  
  var requestToken:BDBOAuth1Credential?
  
  init(){
    
    var test = NSBundle.mainBundle().objectForInfoDictionaryKey("TWEET_CONSUMER_KEY") as! String
    var test2 = NSBundle.mainBundle().objectForInfoDictionaryKey("TWEET_CONSUMER_SECRET") as! String
    println("Consumer key = \(test)")
    println("Consumer secret = \(test2)")
    
    super.init(baseURL: NSURL(string:BaseUrl),
      consumerKey: test,
      consumerSecret: test2)
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
        println("success!")
        self.requestToken = requestToken
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
      success: {(requestToken) -> Void in
        println("got access token success!")
        //let authUrl = "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token)"
        //UIApplication.sharedApplication().openURL(NSURL(string:authUrl)!);
      },
      failure: {(requestTokenError) -> Void in
        println("failed! \(requestTokenError)")
    })
  }

   
}
