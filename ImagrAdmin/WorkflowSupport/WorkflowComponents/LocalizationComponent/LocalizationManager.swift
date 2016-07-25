//
//  LocalizationManager.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/19/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation
import Carbon

class LocalizationManager {
    
    static func keyboardLayouts() -> [String: [String: String]] {
        let dict = NSDictionary(dictionary: [kTISPropertyInputSourceType as String: "TISTypeKeyboardLayout"])
        
        let inputSources = TISCreateInputSourceList(dict, true).takeRetainedValue() as NSArray as! [TISInputSource]
        
        var kbLayouts: [String: [String: String]] = [:]
        for src in inputSources {
            let ptr = TISGetInputSourceProperty(src, kTISPropertyInputSourceID)
            let inputSourceIdentifier = Unmanaged<CFString>.fromOpaque(COpaquePointer(ptr)).takeUnretainedValue() as String
            let srcStr = String(src)
            let nameStart = srcStr.rangeOfString("Layout: ")
            let midStr = srcStr.rangeOfString(" (id=")
            
            let layoutName = srcStr.substringWithRange(nameStart!.endIndex..<midStr!.startIndex)
            let layoutId = srcStr.substringWithRange(midStr!.endIndex..<srcStr.endIndex.advancedBy(-1))
            
            kbLayouts[inputSourceIdentifier] = ["id": layoutId, "name": layoutName]
        }
        return kbLayouts
    }
    
    func matchCountry(countryISO: String) -> Bool {
        let countryCodePlist = NSDictionary(contentsOfFile:"/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/SACountry.plist")
        let countryCodes = countryCodePlist!.allKeys as! [String]
        if countryCodes.contains(countryISO) {
            return true
        } else {
            return false
        }
    }

    
    static func countryCodes() -> [String] {
        let countryCodePlist = NSDictionary(contentsOfFile:"/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/SACountry.plist")
        return countryCodePlist!.allKeys as! [String]
    }

    
    static func getLanguages(countryISO: String) -> [String] {
        let countryLanguageList = NSDictionary(contentsOfFile: "/System/Library/CoreServices/Setup Assistant.app/Contents/Resources/SALanguageToCountry.plist")
        
        var countryLanguageCodesList: [String] = []
        for (countryLanguageCodes, countryLanguages) in countryLanguageList! {
            if (countryLanguages as! [String]).contains(countryISO) {
                countryLanguageCodesList.append(countryLanguageCodes as! String)
            }
        }
        
        return countryLanguageCodesList
    }
    
    static func getTimezones(countryISO: String) -> [String]{
        let countryTimezonesPlist = NSDictionary(contentsOfFile: "/System/Library/PrivateFrameworks/SetupAssistantSupport.framework/Versions/A/Resources/TimeZones.plist")
        var countryTimezones: AnyObject? = countryTimezonesPlist!.valueForKey(countryISO) as? NSDictionary
        
        var timezones: [String] = []
        if countryTimezones == nil {
            countryTimezones = countryTimezonesPlist!.valueForKey(countryISO) as? NSArray ?? []
            timezones = countryTimezones as! [String]
        } else {
            for (_, timezoneName) in countryTimezones as! [String: AnyObject] {
                for zone in timezoneName as! [AnyObject] {
                    timezones.append(zone as! String)
                }
            }
        }
        
        return timezones
    }
    
    static func getInputSources(countryISO: String) -> NSArray {
        let countryInputSources = NSDictionary(contentsOfFile: "/System/Library/PrivateFrameworks/SetupAssistantSupport.framework/Versions/A/Resources/SALocaleToInputSourceID.plist")
        var inputSourceChoices: [String] = []
        for source in countryInputSources!.allKeys {
            if (source as! String).rangeOfString(countryISO) != nil {
                inputSourceChoices = countryInputSources!.valueForKey(source as! String) as! [String]
                break
            }
        }
        
        var allKeyboardLayouts = LocalizationManager.keyboardLayouts()
        var keyboardLayoutNames: [String] = []
        for choice in inputSourceChoices {
            keyboardLayoutNames.append(allKeyboardLayouts[choice]!["name"]!)
        }
        return keyboardLayoutNames
    }
    
    static func getKeyboardLayoutId(layoutName: String) -> String? {
        let allKeyboardLayouts = LocalizationManager.keyboardLayouts()
        var keyboardLayoutId: String?
        for (_, layout) in allKeyboardLayouts {
            if layout["name"] == layoutName {
                keyboardLayoutId = layout["id"]!
                break
            }
        }
        return keyboardLayoutId
    }
}
