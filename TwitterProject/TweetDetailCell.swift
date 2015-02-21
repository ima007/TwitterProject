//
//  TweetDetailCell.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

class TweetDetailCell: UITableViewCell {
  
  
  @IBOutlet weak var profileImage: UIImageView!
  
  @IBOutlet weak var profileName: UILabel!
  
  @IBOutlet weak var profileHandle: UILabel!
  
  @IBOutlet weak var contentLabel: UILabel!
  
  @IBOutlet weak var dateLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func setContent(tweet:Tweet?){
    profileImage.setImageWithURL(tweet?.account?.profileImageNsUrl)
    profileImage.layer.cornerRadius = 3.0
    profileImage.clipsToBounds = true
    
    profileName.text = tweet?.account?.name
    contentLabel.text = tweet?.text
    profileHandle.text = tweet?.account?.screenNameWithAt
    if let date = tweet?.createdAt{
      dateFormatter.dateStyle = .ShortStyle
      dateFormatter.timeStyle = .ShortStyle
      dateLabel.text = dateFormatter.stringFromDate(date)
    }
  }
  
}
