//
//  Crypto.swift
//  ImagrAdmin
//
//  Created by Kyle Crawshaw on 7/25/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation

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