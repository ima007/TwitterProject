//
//  TweetCell.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

let dateFormatter = NSDateFormatter()

class TweetCell: UITableViewCell, TweetCellDelegate {
  @IBOutlet weak private var tweetImage: UIImageView!

  @IBOutlet weak private var nameLabel: UILabel!
  
  @IBOutlet weak private var handleLabel: UILabel!
  
  @IBOutlet weak private var contentLabel: UILabel!
  
  @IBOutlet weak private var dateLabel: UILabel!
  
  @IBOutlet weak private var replyButton: UIButton!
  
  @IBOutlet weak private var retweetButton: UIButton!
  
  @IBOutlet weak private var favoriteButton: UIButton!
  
  var delegate:TweetActionsDelegate?
  
  private var tweet:Tweet?
  var account:Account?
  
  private var allowRetweets:Bool {
    return account?.screen_name != tweet?.account?.screen_name
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
    autoLayoutBug()
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  private func autoLayoutBug(){
    // the preferredMaxLayoutWidth way of working around the issue was causing the intial
    // rendering of the tweet content to have some "padding" around it for some of the cells.
    // only doing "layoutIfNeeded" seems to resolve the issue.
    self.layoutIfNeeded()
  }
  
  func setContents(tweet: Tweet){
    self.tweet = tweet
    tweetImage.setImageWithURL(tweet.account?.profileImageNsUrl)
    tweetImage.layer.cornerRadius = 3.0
    tweetImage.clipsToBounds = true
    
    nameLabel.text = tweet.account?.name
    contentLabel.text = tweet.text
    handleLabel.text = tweet.account?.screenNameWithAt
    
    if let favorited = tweet.favorited{
      favoriteButton.tintColor = favorited ? UIColor.yellowColor() : UIColor.grayColor()
    }
    
    if let retweeted = tweet.retweeted{
      retweetButton.tintColor = retweeted ? UIColor.greenColor() : UIColor.grayColor()
    }
    
    if !allowRetweets {
      retweetButton.alpha = 0.2
    }
    
    if let date = tweet.createdAt{
      dateFormatter.doesRelativeDateFormatting = true
      dateFormatter.dateStyle = .ShortStyle
      dateFormatter.timeStyle = .ShortStyle
      dateLabel.text = dateFormatter.stringFromDate(date)
    }
    
    if tweet.isUpdating{
      UIView.animateWithDuration(0.5, animations: {
        self.dateLabel.alpha = 0.4
        self.contentLabel.alpha = 0.4
        self.nameLabel.alpha = 0.4
      })
    }else{
      UIView.animateWithDuration(0.5, animations: {
        self.dateLabel.alpha = 1.0
        self.contentLabel.alpha = 1.0
        self.nameLabel.alpha = 1.0
      })
    }
  }

  func update(tweet: Tweet) {
    println("updating tweet view")
    setContents(tweet)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    
    autoLayoutBug()
  }
  
  @IBAction func replyAction(sender: AnyObject) {
    delegate?.reply(tweet)
  }
  
  
  @IBAction func retweetAction(sender: AnyObject) {
    if allowRetweets {
      let retweeted = tweet?.retweeted ?? false
      if retweeted{
        delegate?.unretweet(tweet)
      }else{
        delegate?.retweet(tweet)
      }
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
