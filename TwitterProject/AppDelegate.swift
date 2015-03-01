//
//  AppDelegate.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/16/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    
    setTheme()
    
    window = UIWindow(frame: UIScreen.mainScreen().bounds);
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogout", name: accountDidLogoutNotification, object: nil)
    
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidLogin", name: accountDidLoginNotification, object: nil)
    
    if AccountManager.loggedInAccount != nil{
      userDidLogin()
    }else{
      userDidLogout()
    }
    
    return true
  }
  
  func userDidLogin(){
    println("user did login")
    let storyboard = UIStoryboard(name: "Hamburger", bundle: nil)
    let controller = storyboard.instantiateViewControllerWithIdentifier("HamburgerController") as! HamburgerController
    controller.account = AccountManager.loggedInAccount
  
    window?.rootViewController = controller
    window?.makeKeyAndVisible()
  }
  
  func userDidLogout(){
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateInitialViewController() as! UINavigationController
    
    window?.rootViewController = controller
    window?.makeKeyAndVisible()
    
    //let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //let controller = storyboard.instantiateInitialViewController() as! UINavigationController
    /*
    let newStoryboard = UIStoryboard(name: "Main", bundle: nil)
    var controller = newStoryboard.instantiateViewControllerWithIdentifier("LoginController") as! LoginController
    
    let newNavigationController = UINavigationController(rootViewController: controller)
    
    window?.rootViewController?.dismissViewControllerAnimated(true, completion: nil)
    
    //self.presentViewController(newNavigationController, animated: true, completion: nil)
    */
    

  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
    
    Account().api.getAccessToken(url.query!)
    
    return true
  }
  
  private func setTheme(){
    UINavigationBar.appearance().barTintColor = UIColor(twitterHex: "75B4FC")
    UINavigationBar.appearance().tintColor = UIColor.whiteColor()
    
    var attributes = [NSObject:AnyObject]()
    attributes[NSForegroundColorAttributeName] = UIColor(red: 225.0, green: 225.0, blue: 225.0, alpha: 1.0)
    attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 18.0)
    UINavigationBar.appearance().titleTextAttributes = attributes
    
    var attributes2 = [NSObject:AnyObject]()
    attributes2[NSForegroundColorAttributeName] = UIColor(red: 225.0, green: 225.0, blue: 225.0, alpha: 1.0)
    attributes2[NSFontAttributeName] = UIFont(name: "HelveticaNeue", size: 16.0)
    UIBarButtonItem.appearance().setTitleTextAttributes(attributes2, forState: .Normal)
  }


}

