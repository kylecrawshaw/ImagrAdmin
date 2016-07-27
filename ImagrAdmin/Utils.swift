//
//  Crypto.swift
//  ImagrAdmin
//
//  Created by Kyle Crawshaw on 7/25/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation
import Cocoa

// adapted from http://stackoverflow.com/questions/25761344/how-to-crypt-string-to-sha1-with-swift

extension String {
    func sha512() -> String {
        let data = self.dataUsingEncoding(NSUTF8StringEncoding)!
        var digest = [UInt8](count:Int(CC_SHA512_DIGEST_LENGTH), repeatedValue: 0)
        CC_SHA512(data.bytes, CC_LONG(data.length), &digest)
        let hexBytes = digest.map { String(format: "%02hhx", $0) }
        return hexBytes.joinWithSeparator("")
    }
}


func formatMessageString(message: String) -> NSMutableAttributedString {
    let attrStr = NSMutableAttributedString(string: "\(message)\r", attributes: [NSForegroundColorAttributeName: NSColor.blackColor()])
    if message.containsString("WARNING:") {
        attrStr.addAttribute(NSForegroundColorAttributeName, value: NSColor.orangeColor(), range: NSMakeRange(0, 8))
    } else if message.containsString("ERROR:") {
        attrStr.addAttribute(NSForegroundColorAttributeName, value: NSColor.redColor(), range: NSMakeRange(0, 6))
    } else if message.containsString("SUCCESS:") {
        attrStr.addAttribute(NSForegroundColorAttributeName, value: NSColor.greenColor(), range: NSMakeRange(0, 8))
    }
    return attrStr
}
//for line in lines {
//    
//    var range: NSRange?
//    
//    self.validateTextField.textStorage?.appendAttributedString(attrStr)
//    if range != nil {
//        attrStr.removeAttribute(NSForegroundColorAttributeName, range: range!)
//    }
//}