//
//  TweetStatsCell.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

class TweetStatsCell: UITableViewCell, TweetCellDelegate {
  
  @IBOutlet weak var retweetCountLabel: UILabel!
  
  @IBOutlet weak var favoriteCountLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  func update(tweet:Tweet){
    setContent(tweet)
  }
  
  func setContent(tweet:Tweet?){
    retweetCountLabel.text = String(stringInterpolationSegment: tweet?.retweet_count ?? 0)
    favoriteCountLabel.text = String(stringInterpolationSegment: tweet?.favorite_count ?? 0)
  }
  
}
