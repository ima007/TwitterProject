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
  @IBOutlet weak var tweetImage: UIImageView!

  @IBOutlet weak var nameLabel: UILabel!
  
  @IBOutlet weak var handleLabel: UILabel!
  
  @IBOutlet weak var contentLabel: UILabel!
  
  @IBOutlet weak var dateLabel: UILabel!
  
  @IBOutlet weak var replyButton: UIButton!
  
  @IBOutlet weak var retweetButton: UIButton!
  
  @IBOutlet weak var favoriteButton: UIButton!
  
  var delegate:TweetActionsDelegate?
  
  private var tweet:Tweet?
  var account:Account?
  private var favoriteActionIsHappening = false
  
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
          self.setContents(self.tweet!)
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
          self.setContents(self.tweet!)
          self.delegate?.unfavorite(tweet)
          },
          failure: { () -> Void in
            self.favoriteActionIsHappening = false
        })
      }
    }  }
  

}
