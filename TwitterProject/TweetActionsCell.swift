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
  func unretweet(tweet:Tweet?)
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
    }
  }
  
  private func updateRetweet(){
    if let retweeted = tweet?.retweeted{
      retweetButton.tintColor = retweeted ? UIColor.greenColor() : UIColor.grayColor()
    }
  }
  
  @IBAction func replyAction(sender: AnyObject) {
    delegate?.reply(tweet)
  }
  
  @IBAction func retweetAction(sender: AnyObject) {
    let retweeted = tweet?.retweeted ?? false
    if retweeted{
      delegate?.unretweet(tweet)
    }else{
      delegate?.retweet(tweet)
    }
    
  }
  
  @IBAction func favoriteAction(sender: AnyObject) {
    let favorited = tweet?.favorited ?? false
    if  favorited{
      delegate?.unfavorite(tweet)
    }else{
      delegate?.favorite(tweet)
    }
  }
  
  
}
