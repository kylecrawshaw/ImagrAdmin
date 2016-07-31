//
//  ImagrWorkflowManager.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/11/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation
import Cocoa
import AppKit

public class ImagrWorkflowManager {
    
    var name: String!
    var description: String!
    var components: [BaseComponent]!
    var restartAction: String!
    var blessTarget: Bool!
    var hidden: Bool!
    var workflowWindowController: NSWindowController?
    var workflowViewController: WorkflowViewController?
    var workflowWindow: NSWindow?
    var workflowID: Int! = ImagrConfigManager.sharedManager.nextWorkflowID()

    
    init(dict: NSDictionary) {
        self.name = dict.valueForKey("name") as? String! ?? ""
        self.description = dict.valueForKey("description") as? String! ?? ""
        self.restartAction = dict.valueForKey("restart_action") as? String! ?? "none"
        self.blessTarget = dict.valueForKey("bless_target") as? Bool! ?? true
        self.hidden = dict.valueForKey("hidden") as? Bool! ?? false
        // init empty array and then add and init components if necessary
        self.components = []
        if let wfComponents = dict.valueForKey("components") as? [NSDictionary]! {
            for component in wfComponents {
                addComponent(component)
            }
        }
    }
    
    init(name: String, description: String, components: [BaseComponent]?) {
        self.name = name
        self.description = description
        self.components = components ?? []
        self.restartAction = "none"
        self.blessTarget = true
        self.hidden = false
    }
    
    
    func asDict() -> NSDictionary! {
        
        var formattedComponents: [NSDictionary!] = []
        for component in components {
            formattedComponents.append(component.asDict())
        }
        let workflowDict: NSMutableDictionary = [
            "name": name,
            "description": description,
            "components": formattedComponents,
        ]
        
        if restartAction != nil {
            workflowDict.setValue(restartAction, forKey: "restart_action")
        }
        
        if blessTarget != nil {
            workflowDict.setValue(blessTarget, forKey: "bless_target")
        }
        
        if hidden != nil {
            workflowDict.setValue(hidden, forKey: "hidden")
        }
        

        return workflowDict
    }
    
    
    func addComponent(dict: NSDictionary!) {
        
        let componentID = components.count
        guard let type = dict.valueForKey("type") as? String! else {
            return
        }
        let component = newComponentObj(type, id: componentID, workflowName: name, workflowId: workflowID, dict: dict)
        components.append(component as! BaseComponent)
    }

    
    func displayWorkflowWindow() {
        
        if workflowWindowController == nil {
            buildWorkflowWindow()
        }
        workflowWindow!.makeKeyAndOrderFront(self)
        workflowWindowController!.showWindow(self)
        
    }
    
    private func buildWorkflowWindow() {

        workflowViewController = WorkflowViewController()
        workflowViewController!.identifier = String(name)

        workflowWindow = NSWindow(contentViewController: workflowViewController!)
        workflowWindow!.title = "Edit Workflow"
        
        // Set a fixed sized for the workflow window
        let fixedSize = workflowWindow!.frame.size
        workflowWindow!.minSize = fixedSize
        workflowWindow!.maxSize = fixedSize
        
        
        // Hide window title bar buttons
        let closeButton = workflowWindow!.standardWindowButton(NSWindowButton.CloseButton)
        closeButton!.hidden = true
        
        let minButton = workflowWindow!.standardWindowButton(NSWindowButton.MiniaturizeButton)
        minButton!.hidden = true
        
        let maxButton = workflowWindow!.standardWindowButton(NSWindowButton.ZoomButton)
        maxButton!.hidden = true
        
        workflowViewController!.workflowWindow = workflowWindow
        
        workflowWindowController = NSWindowController(window: workflowWindow)
        
    }
}