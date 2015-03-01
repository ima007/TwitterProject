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
  
  func twi_setImageWithName(named:String){
    self.image = UIImage(named: named)
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

// Converted from objective-C
// http://stackoverflow.com/questions/18267211/ios-convert-large-numbers-to-smaller-format
extension Int{
  func abbreviateNumber() -> String?{
    
    
    var abbrevNum:NSString?
    var number = Float(self)
    
    //Prevent numbers smaller than 1000 to return NULL
    if (self >= 1000) {
      var abbrev = ["K", "M", "B"];
      
      for (var i = abbrev.count - 1; i >= 0; i--) {
        
        // Convert array index to "1000", "1000000", etc
        var size = pow(Float(10),Float((i+1)*3));
        
        if(size <= number) {
          // Removed the round and dec to make sure small numbers are included like: 1.1K instead of 1K
          number = number/size;
          var numberString = self.floatToString(number)
          // Add the letter for the abbreviation
          abbrevNum = NSString(format: "%@%@", numberString, abbrev[i])
        }
        
      }
    } else {
      
      // Numbers like: 999 returns 999 instead of NULL
      abbrevNum = NSString(format: "%d", Int(number))
    }
    
    return abbrevNum as String?;
  }
  
  func floatToString(val:Float) -> NSString{
    var ret =  NSString(format: "%.1f", val)
    var c:unichar  = ret.characterAtIndex(ret.length - 1)
    
    while (c == 48) { // 0
      ret = ret.substringToIndex(ret.length - 1)
      c = ret.characterAtIndex(ret.length - 1)
      
      //After finding the "." we know that everything left is the decimal number, so get a substring excluding the "."
      if(c == 46) { // .
        ret = ret.substringToIndex(ret.length - 1)
      }
    }
    
    return ret;
  }
}

extension CGColor {
  
  class func colorWithTwitterHex(hex: String) -> CGColorRef {
    
    return UIColor(twitterHex: hex).CGColor
    
  }
  
}