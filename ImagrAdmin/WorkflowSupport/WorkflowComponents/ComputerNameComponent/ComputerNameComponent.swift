//
//  ImageComponent.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/12/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation
import Cocoa

class ComputerNameComponent: BaseComponent {
    
    var useSerial: Bool!
    var auto: Bool!


    init(id: Int!, workflowName: String!, workflowId: Int!) {
        super.init(id: id, type: "computer_name", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = ComputerNameViewController()
        self.useSerial = false
        self.auto = false
    }
    
    init(id: Int!, workflowName: String!, workflowId: Int!, dict: NSDictionary!) {
        super.init(id: id, type: "computer_name", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = ComputerNameViewController()
        self.useSerial = dict.valueForKey("use_serial") as? Bool ?? false
        self.auto = dict.valueForKey("auto") as? Bool ?? false
    }
    
    override func asDict() -> NSDictionary? {
        var dict: [String: AnyObject] = [
            "type": type,
        ]
        if useSerial == true {
            dict["use_serial"] = useSerial
        }
        
        if auto == true {
            dict["auto"] = auto
        }
        return dict
    }

}