//
//  TweetActionsCell.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

protocol TweetActionsDelegate{
  func reply(tweet:Tweet?)
  func retweet(tweet:Tweet?)
  func favorite(tweet:Tweet?)
  func unfavorite(tweet:Tweet?)
}

class TweetActionsCell: UITableViewCell, TweetCellDelegate {
  
  @IBOutlet weak var replyButton: UIButton!
  
  @IBOutlet weak var retweetButton: UIButton!
  
  @IBOutlet weak var favoriteButton: UIButton!
  
  var account:Account?
  
  private var tweet:Tweet?
  private var retweetedId:String?
  private var retweetActionIsHappening:Bool = false
  private var favoriteActionIsHappening:Bool = false
  
  var delegate:TweetActionsDelegate?
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    backgroundColor = UIColor.whiteColor()
  }
  
  func setContent(tweet:Tweet?){
    self.tweet = tweet
    updateFavorite()
    updateRetweet()
  }
  
  func update(tweet: Tweet) {
    setContent(tweet)
  }
  
  private func updateFavorite(){
    if let favorited = tweet?.favorited{
      favoriteButton.tintColor = favorited ? UIColor.yellowColor() : UIColor.grayColor()
      //favoriteButton.imageView?.twi_setImageWithName(favorited ? "favorite_on" : "favorite")
    }
  }
  
  private func updateRetweet(){
    if let retweeted = tweet?.retweeted{
      retweetButton.tintColor = retweeted ? UIColor.greenColor() : UIColor.grayColor()
      //retweetButton.imageView?.twi_setImageWithName(retweeted ? "retweet_on" : "retweet")
    }
  }
  
  
  
  @IBAction func replyAction(sender: AnyObject) {
    delegate?.reply(tweet)
  }
  
  @IBAction func retweetAction(sender: AnyObject) {
    let retweeted = tweet?.retweeted ?? false
    if !retweetActionIsHappening && !retweeted {
    retweetActionIsHappening = true
      account?.retweet(tweet?.id_str, success: {tweet -> Void in
        self.retweetActionIsHappening = false
        self.tweet?.incrementRetweets()
        self.setContent(self.tweet)
        self.delegate?.retweet(tweet)
        },
        failure: { () -> Void in
        //self.tweet?.incrementRetweets()
        self.retweetActionIsHappening = false
      })
    }

  }
  
  @IBAction func favoriteAction(sender: AnyObject) {
    if !favoriteActionIsHappening{
      let favorited = tweet?.favorited ?? false
      favoriteActionIsHappening = true
      if !favorited{
        println("favoriting")
        account?.favorite(tweet?.id_str, success: {tweet -> Void in
          println("favorited")
          self.favoriteActionIsHappening = false
          self.tweet?.incrementFavorites()
          self.setContent(tweet)
          self.delegate?.favorite(tweet)
          },
          failure: { () -> Void in
            self.favoriteActionIsHappening = false
        })
      }else{
        println("unfavoriting")
        account?.unfavorite(tweet?.id_str, success: {tweet -> Void in
           println("unfavorited")
            self.favoriteActionIsHappening = false
            self.tweet?.decrementFavorites()
            self.setContent(tweet)
            self.delegate?.unfavorite(tweet)
          },
          failure: { () -> Void in
            self.favoriteActionIsHappening = false
        })
      }
    }
  }
  
  
}
