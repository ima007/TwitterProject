//
//  AccountManager.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/18/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import Foundation


var _currentUser: Account?
let CurrentUserKey = "currentUser"
let accountDidLoginNotification = "accountDidLoginNotificaiton"
let accountDidLogoutNotification = "accountDidLogoutNotification"

class AccountManager{

  class var sharedInstance: AccountManager {
    struct Static {
      static let instance:AccountManager = AccountManager()
    }
    return Static.instance
  }
  
  class var loggedInAccount:Account? {
    get{
      if _currentUser == nil{
        var data = NSUserDefaults.standardUserDefaults().objectForKey(CurrentUserKey) as? NSData
        if let data = data {
          var dictionary = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: nil) as? NSDictionary
          if let dictionary = dictionary as? [String : AnyObject]{
            _currentUser = Account(data: dictionary)
          }
        }
      }
      return _currentUser
    }
    set(user){
      _currentUser = user
      if let _currentUser = _currentUser, let dictionary = user?.dictionary{
        let data = NSJSONSerialization.dataWithJSONObject(dictionary, options: nil, error: nil)
        NSUserDefaults.standardUserDefaults().setObject(data, forKey:CurrentUserKey)
      }else{
        NSUserDefaults.standardUserDefaults().setObject(nil, forKey:CurrentUserKey)
      }
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }
  

  func loginNewAccount(){
    //TODO: track references for multiple account loginss
    let newAccount = Account()
    newAccount.login()
  }
  
  func logoutCurrentAccount(){
    AccountManager.loggedInAccount?.logout()
    AccountManager.loggedInAccount = nil
    NSNotificationCenter.defaultCenter().postNotificationName(accountDidLogoutNotification, object: nil)
  }

}
