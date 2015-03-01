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
  var statuses_count:Int?
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
  var profileTextColor:UIColor?
  var profileBackgroundUrl:String?
  var profileImageUrl:String?
  var user_mentions:[Account]?
  lazy var profileImageNsUrl:NSURL? = {
    [unowned self] in
    if let profileImageUrl = self.profileImageUrl{
      return NSURL(string: profileImageUrl)
    }else{
      return nil
    }
  }()
  lazy var profielBackgroudnImageNsUrl:NSURL? = {
    [unowned self] in
    if let profileBackgroundUrl = self.profileBackgroundUrl{
      return NSURL(string: profileBackgroundUrl)
    }else{
      return nil
    }
  }()

  var timeline:[Tweet]?
  var mentions:[Tweet]?
  var userTimelines = [String:[Tweet]?]()
  
  lazy var api:TwitterClient = TwitterClient(account: self)
  
  var retweeting = [String:String]()
  var favoriting = [String:String]()
  
  init(){
    
  }
  
  required init(data: [String : AnyObject]) {
    description <<< data["profile_background_color"]
    profileImageUrl <<< data["profile_image_url"]
    profileBackgroundUrl <<< data["profile_banner_url"]
    name <<< data["name"]
    location <<< data["location"]
    friends_count <<< data["friends_count"]
    followers_count <<< data["followers_count"]
    screen_name <<< data["screen_name"]
    statuses_count <<< data["statuses_count"]
    setBackgroundColor(data)
    setTextColor(data)
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
  
  private func setTextColor(data: [String: AnyObject]){
    var textColorHex:String?
    textColorHex <<< data["profile_text_color"]
    if let textColorHex = textColorHex{
      if count(textColorHex) == 6 {
        profileTextColor = UIColor(twitterHex: textColorHex.uppercaseString)
      }
    }
  }
  
  private func getTimelineTypeParams(#tweets:[Tweet]?, direction:TimelineDirection?) -> [String:String]?{
    var tweet_id:String?
    var load_type:String?
    var params:[String:String]?
    if let direction = direction{
      switch direction{
      case TimelineDirection.OlderTweets:
        tweet_id = tweets?.last?.id_str
        load_type = "max_id"
      case TimelineDirection.NewerTweets:
        tweet_id = tweets?.first?.id_str
        load_type = "since_id"
      default:
        break;
      }
      if let load_type = load_type, let tweet_id = tweet_id {
        params = [String:String]()
        params?.updateValue(tweet_id, forKey: load_type)
      }else{
        params = [String:String]()
      }
    }
    return params
  }
  
  private func handleTimelineSuccess(direction: TimelineDirection?, inout originalTimeline:[Tweet]?, responseTweets:[Tweet]?){
    if let responseTweets = responseTweets, let direction = direction{
      switch direction{
      case TimelineDirection.OlderTweets:
        originalTimeline?.extend(responseTweets)
      case TimelineDirection.NewerTweets:
        originalTimeline?.splice(responseTweets, atIndex: 0)
      default:
        originalTimeline = responseTweets
        break;
      }
    }
  }
  
  func getTimeline(type: TimelineType?, direction: TimelineDirection?, success:([Tweet]? -> Void), failure:()->Void){
    getTimeline(type, direction: direction, screen_name:nil, success:success, failure:failure)
  }
  
  func getTimeline(type: TimelineType?, direction: TimelineDirection?, screen_name:String?, success:([Tweet]? -> Void), failure:()->Void){
    if let type = type{
      switch type{
      case TimelineType.Home:
        api.getTimeline("home",
          params: getTimelineTypeParams(tweets: timeline, direction: direction),
          success: {(tweets) -> Void in
            self.handleTimelineSuccess(direction, originalTimeline: &self.timeline, responseTweets:tweets)
            success(tweets)
          },
          failure: failure)
      case TimelineType.Mentions:
        api.getTimeline("mentions",
          params: getTimelineTypeParams(tweets: mentions, direction: direction),
          success: {(tweets) -> Void in
            self.handleTimelineSuccess(direction, originalTimeline: &self.mentions, responseTweets:tweets)
            success(tweets)
          },
          failure: failure)
      case TimelineType.User:
        if let screen_name = screen_name{
          if userTimelines[screen_name] == nil{
            userTimelines[screen_name] = [Tweet]()
          }
  
          var params = getTimelineTypeParams(tweets: userTimelines[screen_name]!, direction: direction)
          params?.updateValue(screen_name, forKey: "screen_name")
          api.getTimeline("user",
            params: params!,
            success: {(tweets) -> Void in
              self.handleTimelineSuccess(direction, originalTimeline: &self.userTimelines[screen_name]!, responseTweets:tweets)
              success(tweets)
            },
            failure: failure)
        }
      default:
        break
      }
    }
  }
  
  
  
  /*
  * Replies require at least one username in the body
  */
  func sendTweet(content:String?, replyId:String?, success:(Tweet? -> Void), failure:()->Void){
    var params = [String:String]()
    if let content = content{
      params.updateValue(content, forKey: "status")
    }
    if let replyId = replyId{
      params.updateValue(replyId, forKey: "in_reply_to_status_id")
    }
    api.sendTweet(params: params, success: success, failure: failure)
  }
  
  func retweet(tweet:Tweet?, success:(Tweet? -> Void), failure:()->Void){
    if let id = tweet?.id_str {
      let keyIndex = retweeting.indexForKey(id)
      if keyIndex == nil {
        retweeting.updateValue(id, forKey: id)
        
        api.retweet(tweet,
          success: {newTweet -> Void in
            self.retweeting.removeValueForKey(id)
            tweet?.incrementRetweets()
            success(newTweet)
          },
          failure: {() -> Void in
            self.retweeting.removeValueForKey(id)
            failure()
        })
      }
    }
  }
  
  func unretweet(tweet:Tweet?, success:(Tweet? -> Void), failure:()->Void){
    if let id = tweet?.id_str {
      let keyIndex = retweeting.indexForKey(id)
      if keyIndex == nil {
        retweeting.updateValue(id, forKey: id)
        
        api.unretweet(tweet,
          success: {newTweet -> Void in
            self.retweeting.removeValueForKey(id)
            tweet?.decrementRetweets()
            success(newTweet)
          },
          failure: {() -> Void in
            self.retweeting.removeValueForKey(id)
            failure()
        })
      }
    }
  }
  
  func favorite(tweet:Tweet?, success:(Tweet? -> Void), failure:()->Void){
    favorite(tweet?.id_str,
      success: {newTweet -> Void in
      tweet?.incrementFavorites()
      success(newTweet)
    }, failure: failure)
  }
  
  func unfavorite(tweet:Tweet?, success:(Tweet? -> Void), failure:()->Void){
    unfavorite(tweet?.id_str,
      success: {newTweet -> Void in
        tweet?.decrementFavorites()
        success(newTweet)
      }, failure: failure)
  }
  
  func favorite(id:String?, success:(Tweet? -> Void), failure:()->Void){
    if let id = id {
      let keyIndex = favoriting.indexForKey(id)
      if keyIndex == nil {
        favoriting.updateValue(id, forKey: id)
        
        api.favorite(id,
          success: {tweet -> Void in
            self.favoriting.removeValueForKey(id)
            success(tweet)
          },
          failure: {() -> Void in
            self.favoriting.removeValueForKey(id)
            failure()
        })
      }
    }
  }
  func unfavorite(id:String?, success:(Tweet? -> Void), failure:()->Void){
    if let id = id {
      let keyIndex = favoriting.indexForKey(id)
      if keyIndex == nil {
        favoriting.updateValue(id, forKey: id)
        
        api.unfavorite(id,
          success: {tweet -> Void in
            self.favoriting.removeValueForKey(id)
            success(tweet)
          },
          failure: {() -> Void in
            self.favoriting.removeValueForKey(id)
            failure()
        })
      }
    }
  }
  
  func logout(){
    api.requestSerializer.removeAccessToken()
  }
  
  func login(){
    //Start the login process. Will emit notification when done.
    //AppDelegate will open the right view.
    api.getRequestToken()
  }
  
   deinit { /*println("\(name) is being deinitialized")*/ }
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