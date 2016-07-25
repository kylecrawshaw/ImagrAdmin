//
//  PackageComponent.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/13/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation

class ScriptComponent: BaseComponent {
    
    var URL: String?
    var content: String?
    var firstBoot: Bool?
        
    init(id: Int!, workflowName: String!, workflowId: Int!) {
        super.init(id: id, type: "script", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = ScriptComponentViewController()
        self.URL = nil
        self.content = nil
        self.firstBoot = true
    }
    
    init(id: Int!, workflowName: String!, workflowId: Int!, dict: NSDictionary!) {
        super.init(id: id, type: "script", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = ScriptComponentViewController()
        self.URL = dict.valueForKey("url") as? String
        self.content = dict.valueForKey("content") as? String
        self.firstBoot = dict.valueForKey("first_boot") as? Bool ?? true
    }
    
    override func asDict() -> NSDictionary? {
        var dict: [String: AnyObject] = [
            "type": type,
        ]
        if URL != nil {
            dict["url"] = URL
        }
        if content != nil {
            dict["content"] = content
        }
        if firstBoot != nil {
            dict["first_boot"] = firstBoot
        }
        return dict
    }

}