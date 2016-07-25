//
//  ImageComponent.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/12/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation
import Cocoa

class LocalizationComponent: BaseComponent {
    
    var keyboardLayoutName: String?
    var keyboardLayoutId: String?
    var countryCode: String?
    var language: String?
    var timezone: String?
//    var locale: String?


    init(id: Int!, workflowName: String!, workflowId: Int!) {
        super.init(id: id, type: "localize", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = LocalizationComponentViewController()
    }
    
    init(id: Int!, workflowName: String!, workflowId: Int!, dict: NSDictionary!) {
        super.init(id: id, type: "localize", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = LocalizationComponentViewController()
        self.keyboardLayoutName = dict.valueForKey("keyboard_layout_name") as? String
        self.keyboardLayoutId = dict.valueForKey("keyboard_layout_id") as? String
        self.timezone = dict.valueForKey("timezone") as? String
        self.language = dict.valueForKey("language") as? String
        
        if let locale = dict.valueForKey("locale") as? String {
            let localeComponents = locale.characters.split{$0 == "_"}.map(String.init)
            if localeComponents.count == 1 {
                self.countryCode = localeComponents[0]
            } else if localeComponents.count == 2 {
                self.countryCode = localeComponents[1]
            }
        }
    }
    
    override func asDict() -> NSDictionary? {
        var dict: [String: AnyObject] = [
            "type": type,
        ]
        
        if (keyboardLayoutName != nil) && (keyboardLayoutName != "") {
            dict["keyboard_layout_name"] = keyboardLayoutName!
        }
        
        if (keyboardLayoutId != nil) && (keyboardLayoutId != "" ){
            dict["keyboard_layout_id"] = Int(keyboardLayoutId!)
        }
        
        if (language != nil) && (language! != "") {
            dict["language"] = language!
        }
        
        if (countryCode != nil && countryCode! != "" && language != nil) {
            dict["locale"] = "\(language!)_\(countryCode!)"
        }
        
        if (timezone != nil) && (timezone != "") {
            dict["timezone"] = timezone!
        }
        return dict
    }

}