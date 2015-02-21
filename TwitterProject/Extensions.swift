//
//  Extensions.swift
//  TwitterProject
//
//  Created by Shane Afsar on 2/20/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

extension UIImageView{
  func twi_setImageWithUrl(url:NSURL?){
    if let url = url{
      self.setImageWithURL(url)
    }
  }
}

extension UIColor {
  
  convenience init(twitterHex: String) {
    var hex:UInt32 = 0
    NSScanner(string: twitterHex).scanHexInt(&hex)

    let components = (
      R: CGFloat((hex >> 16) & 0xff) / 255,
      G: CGFloat((hex >> 08) & 0xff) / 255,
      B: CGFloat((hex >> 00) & 0xff) / 255
    )
    
    self.init(red: components.R, green: components.G, blue: components.B, alpha: 1)
    
  }
  
}

extension CGColor {
  
  class func colorWithTwitterHex(hex: String) -> CGColorRef {
    
    return UIColor(twitterHex: hex).CGColor
    
  }
  
}