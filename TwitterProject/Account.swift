//
//  Account.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/18/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import Foundation

class Account:Deserializable {
  var dictionary:NSDictionary?
  var followers_count:Int?
  var friends_count:Int?
  var name:String?
  var screen_name:String?
  var screenNameWithAt:String? {
    if let screen_name = screen_name{
      return "@"+screen_name
    }
    return nil
  }
  var location:String?
  var description:String?
  var profileBackgroundColor:UIColor?
  var profileImageUrl:String?
  lazy var profileImageNsUrl:NSURL? = {
    [unowned self] in
    if let profileImageUrl = self.profileImageUrl{
      return NSURL(string: profileImageUrl)
    }else{
      return nil
    }
  }()

  var timeline:[Tweet]?
  
  lazy var api:TwitterClient = TwitterClient(account: self)
  
  init(){
    
  }
  
  required init(data: [String : AnyObject]) {
    description <<< data["profile_background_color"]
    profileImageUrl <<< data["profile_image_url"]
    name <<< data["name"]
    location <<< data["location"]
    friends_count <<< data["friends_count"]
    followers_count <<< data["followers_count"]
    screen_name <<< data["screen_name"]
    setBackgroundColor(data)
    dictionary = data
  }
  
  private func setBackgroundColor(data: [String : AnyObject]){
    var backgroundColorHex:String?
    backgroundColorHex <<< data["profile_background_color"]
    if let backgroundColorHex = backgroundColorHex{
      if count(backgroundColorHex) == 6 {
        profileBackgroundColor = UIColor(twitterHex: backgroundColorHex.uppercaseString)
      }
    }
  }
  
  func getHomeTimeline(success:([Tweet]? -> Void), failure:()->Void){
    println("getting home timline")
    api.getHomeTimeline({(tweets) -> Void in
        self.timeline = tweets
        success(tweets)
      }, failure: failure)
  }
  
  private func getTimelineTypeParams(type:TimelineType?) -> [String:String]?{
    var tweet_id:String?
    var load_type:String?
    var params:[String:String]?
    if let type = type{
      switch type{
      case TimelineType.OlderTweets:
        tweet_id = timeline?.last?.id_str
        load_type = "max_id"
      case TimelineType.NewerTweets:
        tweet_id = timeline?.first?.id_str
        load_type = "since_id"
      default:
        break;
      }
      if let load_type = load_type, let tweet_id = tweet_id {
        params = [String:String]()
        params?.updateValue(tweet_id, forKey: load_type)
      }
    }
    return params
  }
  
  func getHomeTimeline(type: TimelineType?,success:([Tweet]? -> Void), failure:()->Void){
    println("getting home timline with params")

    var params = getTimelineTypeParams(type)

    api.getHomeTimeline(params: params, success: {(tweets) -> Void in
      if let type = type, let tweets = tweets{
        switch type{
        case TimelineType.OlderTweets:
          self.timeline?.extend(tweets)
        case TimelineType.NewerTweets:
          self.timeline?.splice(tweets, atIndex: 0)
        default:
          self.timeline = tweets
          break;
        }
      }
      
      success(tweets)
      }, failure: failure)
  }
  
  func logout(){
    api.requestSerializer.removeAccessToken()
  }
  
  func login(){
    api.getRequestToken()
  }
  
   deinit { println("\(name) is being deinitialized") }
}

/*
{
"contributors_enabled": true,
"created_at": "Sat May 09 17:58:22 +0000 2009",
"default_profile": false,
"default_profile_image": false,
"description": "I taught your phone that thing you like.  The Mobile Partner Engineer @Twitter. ",
"favourites_count": 588,
"follow_request_sent": null,
"followers_count": 10625,
"following": null,
"friends_count": 1181,
"geo_enabled": true,
"id": 38895958,
"id_str": "38895958",
"is_translator": false,
"lang": "en",
"listed_count": 190,
"location": "San Francisco",
"name": "Sean Cook",
"notifications": null,
"profile_background_color": "1A1B1F",
"profile_background_image_url": "http://a0.twimg.com/profile_background_images/495742332/purty_wood.png",
"profile_background_image_url_https": "https://si0.twimg.com/profile_background_images/495742332/purty_wood.png",
"profile_background_tile": true,
"profile_image_url": "http://a0.twimg.com/profile_images/1751506047/dead_sexy_normal.JPG",
"profile_image_url_https": "https://si0.twimg.com/profile_images/1751506047/dead_sexy_normal.JPG",
"profile_link_color": "2FC2EF",
"profile_sidebar_border_color": "181A1E",
"profile_sidebar_fill_color": "252429",
"profile_text_color": "666666",
"profile_use_background_image": true,
"protected": false,
"screen_name": "theSeanCook",
"show_all_inline_media": true,
"status": {
"contributors": null,
"coordinates": {
"coordinates": [
-122.45037293,
37.76484123
],
"type": "Point"
},
"created_at": "Tue Aug 28 05:44:24 +0000 2012",
"favorited": false,
"geo": {
"coordinates": [
37.76484123,
-122.45037293
],
"type": "Point"
},
"id": 240323931419062272,
"id_str": "240323931419062272",
"in_reply_to_screen_name": "messl",
"in_reply_to_status_id": 240316959173009410,
"in_reply_to_status_id_str": "240316959173009410",
"in_reply_to_user_id": 18707866,
"in_reply_to_user_id_str": "18707866",
"place": {
"attributes": {},
"bounding_box": {
"coordinates": [
[
[
-122.45778216,
37.75932999
],
[
-122.44248216,
37.75932999
],
[
-122.44248216,
37.76752899
],
[
-122.45778216,
37.76752899
]
]
],
"type": "Polygon"
},
"country": "United States",
"country_code": "US",
"full_name": "Ashbury Heights, San Francisco",
"id": "866269c983527d5a",
"name": "Ashbury Heights",
"place_type": "neighborhood",
"url": "http://api.twitter.com/1/geo/id/866269c983527d5a.json"
},
"retweet_count": 0,
"retweeted": false,
"source": "<a>Twitter for  iPhone</a>",
"text": "@messl congrats! So happy for all 3 of you.",
"truncated": false
},
"statuses_count": 2609,
"time_zone": "Pacific Time (US & Canada)",
"url": null,
"utc_offset": -28800,
"verified": false
}
*/