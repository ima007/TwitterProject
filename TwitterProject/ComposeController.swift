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
  
  @IBOutlet weak var characterCountLabel: UILabel!
  @IBOutlet weak var profileScreenName: UILabel!
  
  var delegate: ComposeModalDelegate?
  var account: Account?
  var tweet: Tweet?
  
  let MaxCharLength = 140
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    profileImage.twi_setImageWithUrl(account?.profileImageNsUrl)
    profileName.text = account?.name
    profileScreenName.text = account?.screenNameWithAt
    
    tweetInput.delegate = self
    
    setMentions()
    
    setTitleCount()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  func setTitleCount(){
    if let text = tweetInput.text {
      characterCountLabel.text = String(count(text.utf16))
      if count(text.utf16) > MaxCharLength {
        characterCountLabel.textColor = UIColor.redColor()
      }else{
        characterCountLabel.textColor = UIColor.grayColor()
      }
    }else{
      characterCountLabel.text = "0"
    }
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
      if count(tweetInput.text.utf16) <= MaxCharLength  {
        submit(text)
      }else{
        showLengthError()
      }
    }
  }
  
  private func showLengthError(){
    var alert = UIAlertView(title: "Dang.", message: "Shorten that message, then we'll let it through.", delegate: self, cancelButtonTitle: "Ok, I will")
    alert.show()
  }
  
  private func submit(text:String){
    var customId = NSUUID().UUIDString as String
    var newTweet = Tweet.placeholderToBeUpdated(text, account: account)
    
    delegate?.sent(self, newTweet: newTweet)
    
    account?.sendTweet(
      text,
      replyId: tweet?.id_str,
      success: { (finalTweet) -> Void in
        if let finalTweet = finalTweet{
          newTweet.update(finalTweet)
        }else{
          //Fail condition
        }
      },
      failure: { () -> Void in
         //Fail condition
    })
  }

  
}

extension ComposeController:UITextViewDelegate{
  func textViewDidChange(textView: UITextView) {
    setTitleCount()
  }
  
  
  // Prevents typing over 140 characters
  // Other approach (currently implemented) would be to just let 
  // the typing happen, and not allow the tweet button to be 
  // pressed if it's over 140.
  
  /*
  func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
    if range.length + range.location > textView.text.utf16Count{
      return false
    }
    var newLength = textView.text.utf16Count + text.utf16Count - range.length
    return newLength <= 140
  }
  */
}
