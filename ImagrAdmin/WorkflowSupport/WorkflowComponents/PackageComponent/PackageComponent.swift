//
//  PackageComponent.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/13/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation

class PackageComponent: BaseComponent {
    
    var URL: String!
    var firstBoot: Bool?
        
    init(id: Int!, workflowName: String!, workflowId: Int!) {
        super.init(id: id, type: "package", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = PackageComponentViewController()
        self.URL = ""
        self.firstBoot = true
    }
    
    init(id: Int!, workflowName: String!, workflowId: Int!, dict: NSDictionary!) {
        super.init(id: id, type: "package", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = PackageComponentViewController()
        self.URL = dict.valueForKey("url") as? String ?? ""
        self.firstBoot = dict.valueForKey("first_boot") as? Bool ?? true
    }
    
    override func asDict() -> NSDictionary? {
        var dict: [String: AnyObject] = [
            "type": type,
            "url": URL,
        ]
        if firstBoot != nil {
            dict["first_boot"] = firstBoot
        }
        return dict
    }

}