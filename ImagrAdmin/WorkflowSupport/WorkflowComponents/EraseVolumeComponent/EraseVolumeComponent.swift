//
//  ImageComponent.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/12/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation
import Cocoa

class EraseVolumeComponent: BaseComponent {
    
    var volumeName: String!
    var volumeFormat: String!


    init(id: Int!, workflowName: String!, workflowId: Int!) {
        super.init(id: id, type: "eraseVolume", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = EraseVolumeViewController()
        self.volumeName = ""
        self.volumeFormat = "Journaled HFS+"
    }
    
    init(id: Int!, workflowName: String!, workflowId: Int!, dict: NSDictionary!) {
        super.init(id: id, type: "eraseVolume", workflowName: workflowName, workflowId: workflowId)
        super.componentViewController = EraseVolumeViewController()
        self.volumeName = dict.valueForKey("name") as? String ?? ""
        self.volumeFormat = dict.valueForKey("format") as? String ?? "Journaled HFS+"
    }
    
    override func asDict() -> NSDictionary? {
        let dict: [String: AnyObject] = [
            "type": type,
            "name": volumeName,
            "format": volumeFormat
        ]
        return dict
    }

}