//
//  ImagrConfigManager.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/11/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation

public class ImagrConfigManager {
    
    public static let sharedManager = ImagrConfigManager()
    
    var imagrConfigPath: String?
    var password: String?
    var workflows: [ImagrWorkflowManager]! = []
    var defaultWorkflow: String?
    var backgroundImage: String?
    var autorunWorkflow: String?
    private var configData: NSDictionary! = NSDictionary()
    var hasLoaded: Bool = false

    
    public func loadConfig(path: String!) {
        NSLog("Initialized ImagrConfigManager.sharedManager with \(path)")
        imagrConfigPath = path
        
        if NSFileManager.defaultManager().fileExistsAtPath(imagrConfigPath!) {
            configData = NSMutableDictionary(contentsOfFile: imagrConfigPath!)
        } else {
            configData = NSMutableDictionary()
        }
        password = configData!["password"] as? String
        defaultWorkflow = configData!["default_workflow"] as? String
        autorunWorkflow = configData!["autorun"] as? String
        backgroundImage = configData!["background_image"] as? String
        
        let workflowsFromConfig = configData["workflows"] as? [AnyObject] ?? []
        for workflow in workflowsFromConfig {
            workflows.append(ImagrWorkflowManager(dict: workflow as! NSDictionary))
        }
        hasLoaded = true
    }
    
    public func nextWorkflowID() -> Int! {
        return workflows.count
    }
    
    public func getWorkflow(name: String!) -> ImagrWorkflowManager? {
        var workflow: ImagrWorkflowManager?
        for possibleWorkflow in workflows! {
            if possibleWorkflow.name == name {
                workflow = possibleWorkflow
                break
            }
        }
        return workflow
    }
    
    public func getWorkflowByID(id: Int!) -> ImagrWorkflowManager? {
        var workflow: ImagrWorkflowManager?
        for possibleWorkflow in workflows! {
            if possibleWorkflow.workflowID == id {
                workflow = possibleWorkflow
                break
            }
        }
        return workflow
    }
    
    
    public func getComponent(viewIdentifier: String!) -> BaseComponent? {
        let viewIdentifierSplit = viewIdentifier.characters.split{$0 == "-"}.map(String.init)
        let workflowId = Int(viewIdentifierSplit[0])
        let componentId = Int(viewIdentifierSplit[1])
        let workflow = getWorkflowByID(workflowId)
        var workflowComponent: BaseComponent?
        for component in workflow!.components {
            if component.id == componentId {
                workflowComponent = component
            }
        }
        return workflowComponent
    }
    
    public func getWorkflowForView(viewIdentifier: String) -> ImagrWorkflowManager? {
        let viewIdentifierSplit = viewIdentifier.characters.split{$0 == "-"}.map(String.init)
        let workflowId = viewIdentifierSplit[0]
        return getWorkflowByID(Int(workflowId))
    }
    
    public func workflowTitles() -> [String] {
        var workflowTitleList: [String] = []
        for workflow in workflows! {
            workflowTitleList.append(workflow.name)
        }
        return workflowTitleList
    }

    
    public func asDict() -> NSDictionary {
        updateConfigDict()
        return configData
    }
    
    private func updateConfigDict() {
        configData.setValue(password, forKey: "password")
        configData.setValue(defaultWorkflow, forKey: "default_workflow")
        configData.setValue(autorunWorkflow, forKey: "autorun")
        configData.setValue(backgroundImage, forKey: "background_image")
        
        var formattedWorkflows: [NSDictionary] = []
        if workflows != nil {
            for workflow in workflows! {
                formattedWorkflows.append(workflow.asDict())
            }
        }
        
        if formattedWorkflows.count > 0 {
            configData.setValue(formattedWorkflows, forKey: "workflows")
        }
        NSLog("Updating configData from ImagrConfigManager")
    }
    
    public func save() {
        updateConfigDict()
        configData.writeToFile(imagrConfigPath!, atomically: false)
    }
    
    public func save(path: String) {
        updateConfigDict()
        configData.writeToFile(path, atomically: false)
    }
    
}
