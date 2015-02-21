//
//  Tweet.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/18/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import Foundation

class Tweet:Deserializable{

  var account:Account?
  var text:String?
  var id_str:String?
  var retweeted:Bool?
  var retweet_count:Int?
  var favorite_count:Int?
  var favorited:Bool?
  
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
  
  required init(data: [String : AnyObject]) {
    account <<<< data["user"]
    text <<< data["text"]
    id_str <<< data["id_str"]
    retweet_count <<< data["retweet_count"]
    favorite_count <<< data["favorite_count"]
    favorited <<< data["favorited"]
    retweeted <<< data["retweeted"]
    createdAtUnformatted <<< data["created_at"]
  }
  
}

