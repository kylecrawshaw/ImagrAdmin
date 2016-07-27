//
//  IncludedWorkflowComponent.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/15/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation

class IncludedWorkflowComponent: BaseComponent {
    
    var includedWorkflow: String?
    var script: String?
    
    init(id: Int!, workflowName: String!, workflowId: Int!) {
        super.init(id: id, type: "included_workflow", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = IncludedWorkflowViewController()
    }
    
    init(id: Int!, workflowName: String!, workflowId: Int!, dict: NSDictionary!) {
        super.init(id: id, type: "included_workflow", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = IncludedWorkflowViewController()
        self.includedWorkflow = dict.valueForKey("included_workflow") as? String
        self.script = dict.valueForKey("script") as? String
    }
    
    override func asDict() -> NSDictionary? {
        var dict: [String: AnyObject] = [
            "type": type,
        ]
        if includedWorkflow != nil {
            dict["name"] = includedWorkflow!
        }
        if script != nil {
            dict["script"] = script!
        }
        return dict
    }
}