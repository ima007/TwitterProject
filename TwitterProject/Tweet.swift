//
//  Tweet.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/18/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import Foundation

protocol TweetCellDelegate{
  func update(tweet:Tweet)
}

class Tweet:Deserializable{

  var account:Account?
  var text:String?
  var id_str:String?
  var retweeted:Bool?
  var retweet_count:Int?
  var favorite_count:Int?
  var favorited:Bool?
  var user_mentions:[Account]?
  var current_user_retweet:String?
  
  var isUpdating:Bool = false
  
  var delegate:TweetCellDelegate?
  
  private var createdAtUnformatted:String?
  lazy var createdAt:NSDate? = {
    [unowned self] in
     return Tweet.formatter.dateFromString(self.createdAtUnformatted!)
  }()
  
  class var formatter:NSDateFormatter{
    struct Static{
      static let formatter = NSDateFormatter()
    }
    Static.formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
    return Static.formatter
  }
  
  init(){
    
  }
  
  required init(data: [String : AnyObject]) {
    account <<<< data["user"]
    text <<< data["text"]
    id_str <<< data["id_str"]
    current_user_retweet <<< data["current_user_retweet"]
    retweet_count <<< data["retweet_count"]
    favorite_count <<< data["favorite_count"]
    favorited <<< data["favorited"]
    retweeted <<< data["retweeted"]
    createdAtUnformatted <<< data["created_at"]
    var entities:[String : AnyObject]?
    entities <<< data["entities"]
    if let entities = entities{
      user_mentions <<<<* entities["user_mentions"]
    }
  }
  
  class func placeholderToBeUpdated(text:String, account:Account?) -> Tweet{
    var customId = NSUUID().UUIDString as String
    var newTweet = Tweet()
    newTweet.text = text
    newTweet.account = account
    newTweet.createdAt = NSDate()
    newTweet.favorite_count = 0
    newTweet.retweet_count = 0
    newTweet.id_str = customId
    newTweet.isUpdating = true
    return newTweet
  }

  
  
  func update(tweet:Tweet){
    println("updating tweet")
    account = tweet.account
    text = tweet.text
    println("\(tweet.id_str)")
    id_str = tweet.id_str
    retweet_count = tweet.retweet_count
    favorite_count = tweet.favorite_count
    favorited = tweet.favorited
    retweeted = tweet.retweeted
    createdAtUnformatted = tweet.createdAtUnformatted
    isUpdating = tweet.isUpdating
    user_mentions = tweet.user_mentions
    delegate?.update(self)
  }
  
  func incrementFavorites(){
    favorited = true
    if let favoriteCount = favorite_count{
      favorite_count = favoriteCount + 1
    }else{
      favorite_count = 1
    }
    delegate?.update(self)
  }
  
  func incrementRetweets(){
    retweeted = true
    if let retweetCount = retweet_count{
      retweet_count = retweetCount + 1
    }else{
      retweet_count = 0
    }
    delegate?.update(self)
  }
  
  func decrementFavorites(){
    favorited = false
    if let favoriteCount = favorite_count{
      favorite_count = favoriteCount - 1
    }else{
      favorite_count = 0
    }
    delegate?.update(self)
  }
  
  func decrementRetweets(){
    retweeted = false
    if let retweetCount = retweet_count{
      retweet_count = retweetCount - 1
    }else{
      retweet_count = 0
    }
    delegate?.update(self)
  }
  
  deinit {
    /* println("Tweet is being deinitialized") */
  }
  
}

