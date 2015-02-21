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
    contentLabel.preferredMaxLayoutWidth = contentLabel.frame.size.width
  }
  
  func setContents(tweet: Tweet){
    if let url = tweet.account?.profileImageUrl{
      tweetImage.setImageWithURL(NSURL(string:url))
      tweetImage.layer.cornerRadius = 3.0
      tweetImage.clipsToBounds = true
    }
    nameLabel.text = tweet.account?.name
    contentLabel.text = tweet.text
    handleLabel.text = tweet.account?.handle
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
