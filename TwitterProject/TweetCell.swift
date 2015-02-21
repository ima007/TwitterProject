//
//  TweetCell.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

let dateFormatter = NSDateFormatter()

class TweetCell: UITableViewCell {
  @IBOutlet weak var tweetImage: UIImageView!

  @IBOutlet weak var nameLabel: UILabel!
  
  @IBOutlet weak var handleLabel: UILabel!
  
  @IBOutlet weak var contentLabel: UILabel!
  
  @IBOutlet weak var dateLabel: UILabel!
  
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
    /*
    if contentLabel.preferredMaxLayoutWidth != contentLabel.frame.size.width {
      //contentLabel.preferredMaxLayoutWidth = contentLabel.frame.size.width
      //contentLabel.setNeedsUpdateConstraints()
    }
    */
  }
  
  func setContents(tweet: Tweet){

    tweetImage.setImageWithURL(tweet.account?.profileImageNsUrl)
    tweetImage.layer.cornerRadius = 3.0
    tweetImage.clipsToBounds = true
    
    nameLabel.text = tweet.account?.name
    contentLabel.text = tweet.text
    handleLabel.text = tweet.account?.screenNameWithAt
    if let date = tweet.createdAt{
      dateFormatter.doesRelativeDateFormatting = true
      dateFormatter.dateStyle = .ShortStyle
      dateFormatter.timeStyle = .ShortStyle
      dateLabel.text = dateFormatter.stringFromDate(date)
    }
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    autoLayoutBug()
  }

}
