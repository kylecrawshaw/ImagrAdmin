//
//  BaseComponent.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/12/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation
import Cocoa

public class BaseComponent {
    
    var type: String!
    var id: Int!
    var workflowName: String!
    var workflowId: Int!
    var componentViewController: NSViewController?
    var componentWindowController: NSWindowController?
    var componentWindow: NSWindow?
    
    init(id: Int!, type: String!, workflowName: String!, workflowId: Int!) {
        self.id = id
        self.type = type
        self.workflowName = workflowName
        self.workflowId = workflowId
    }
    
    func asDict() -> NSDictionary? {return nil}
    
    func displayComponentPanel(window: NSWindow!) {
        if componentWindowController == nil {
            componentWindow = NSWindow(contentViewController: componentViewController!)
            componentWindow!.title = "Edit component"
            componentWindowController = NSWindowController(window: componentWindow)
            buildComponentPanel()
        }
        componentViewController!.identifier = "\(workflowId)-\(id)"
        window.beginSheet(componentWindow!, completionHandler: nil)
        componentWindow!.makeKeyAndOrderFront(self)
        componentWindowController!.showWindow(self)
    }
    
    func closeComponentPanel() {
        let workflow = ImagrConfigManager.sharedManager.getWorkflow(workflowName)
        
        if workflow != nil {
            NSLog("Closing component panel for \(type)-\(id) in \(workflowName)")
            if workflow!.workflowWindow!.sheets.count > 0 {
                workflow!.workflowWindow!.endSheet(workflow!.workflowWindow!.sheets[0])
            }
        } else {
            NSLog("Missing workflow object for \(workflowName). Unable to close panel")
        }

    }
    
    func buildComponentPanel() {}
    
    
    func notifyUpdateTable() {
        NSLog("Notifying window for workflow with ID:\(workflowId!).")
        NSNotificationCenter.defaultCenter().postNotificationName("UpdateTableView-\(workflowId!)", object: nil)
    }
}