//
//  ImageComponent.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/12/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation
import Cocoa

class ImageComponent: BaseComponent {
    
    var URL: String!
    var verify: Bool!


    init(id: Int!, workflowName: String!, workflowId: Int!) {
        super.init(id: id, type: "image", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = ImageComponentViewController()
        self.URL = ""
        self.verify = true
    }
    
    init(id: Int!, workflowName: String!, workflowId: Int!, dict: NSDictionary!) {
        super.init(id: id, type: "image", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = ImageComponentViewController()
        self.URL = dict.valueForKey("url") as? String ?? ""
        self.verify = dict.valueForKey("verify") as? Bool ?? true
    }
    
    override func asDict() -> NSDictionary? {
        var dict: [String: AnyObject] = [
            "type": type,
            "url": URL,
        ]
        if verify != nil {
            dict["verify"] = verify
        }
        return dict
    }

}