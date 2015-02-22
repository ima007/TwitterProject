//
//  ComposeController.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/21/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

protocol ComposeModalDelegate{
  func dismissed(controller:ComposeController)
  
  func sent(controller:ComposeController, newTweet: Tweet?)

}

class ComposeController: UIViewController {
  
  @IBOutlet weak var tweetInput: UITextView!
  @IBOutlet weak var profileImage: UIImageView!
  @IBOutlet weak var profileName: UILabel!
  
  @IBOutlet weak var profileScreenName: UILabel!
  
  var delegate: ComposeModalDelegate?
  var account: Account?
  var tweet: Tweet?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    profileImage.twi_setImageWithUrl(account?.profileImageNsUrl)
    profileName.text = account?.name
    profileScreenName.text = account?.screenNameWithAt
    
    setMentions()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setMentions(){
    if let tweet = tweet{
      var mentions = [String]()
      if let screenName = tweet.account?.screenNameWithAt{
        mentions.append(screenName)
        tweetInput.text = screenName
        
        if let userMentions = tweet.user_mentions{
          for account in userMentions{
            if let screenNameWithAt = account.screenNameWithAt{
              if !contains(mentions, screenNameWithAt) {
                tweetInput.text = tweetInput.text + " "+screenNameWithAt
                mentions.append(screenNameWithAt)
              }
            }
          }
        }
        tweetInput.text = tweetInput.text + " "
      }
    }
  }
  
  
  @IBAction func tappedCancelButton(sender: AnyObject) {
    delegate?.dismissed(self)
  }
  

  @IBAction func tappedSendButton(sender: AnyObject) {
    if let text = tweetInput.text {
      var customId = NSUUID().UUIDString as String
      var newTweet = Tweet()
      newTweet.text = text
      newTweet.account = account
      newTweet.createdAt = NSDate()
      newTweet.favorite_count = 0
      newTweet.retweet_count = 0
      newTweet.id_str = customId
      newTweet.isUpdating = true
      delegate?.sent(self, newTweet: newTweet)
      account?.sendTweet(
        text,
        replyId: tweet?.id_str,
        success: { (finalTweet) -> Void in
          if let finalTweet = finalTweet{
            newTweet.update(finalTweet)
          }else{
            //self.delegate?.failedFinal(customId)
          }
        },
        failure: { () -> Void in
          //self.delegate?.failedFinal(customId)
      })
    }
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
