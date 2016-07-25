//
//  RegisteredComponents.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/14/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Foundation

let registeredComponents: Array<String> = [
    "image",
    "package",
    "script",
    "included_workflow",
    "computer_name",
    "eraseVolume",
    "localize"
]

//let registerObj = (ImageComponent, PackageComponent)

func newComponentObj(type: String!, id: Int!, workflowId: Int!, workflowName: String!) -> AnyObject? {
    switch type {
    case "image":
        return ImageComponent(id: id, workflowName: workflowName,  workflowId: workflowId)
    case "package":
        return PackageComponent(id: id, workflowName: workflowName, workflowId: workflowId)
    case "included_workflow":
        return IncludedWorkflowComponent(id: id, workflowName: workflowName, workflowId: workflowId)
    case "computer_name":
        return ComputerNameComponent(id: id, workflowName: workflowName, workflowId: workflowId)
    case "eraseVolume":
        return EraseVolumeComponent(id: id, workflowName: workflowName, workflowId: workflowId)
    case "script":
        return ScriptComponent(id: id, workflowName: workflowName, workflowId: workflowId)
    case "localize":
        return LocalizationComponent(id: id, workflowName: workflowName, workflowId: workflowId)
    default:
        return nil
    }
}

func newComponentObj(type: String!, id: Int!, workflowName: String!, workflowId: Int!, dict: NSDictionary!) -> AnyObject? {
    switch type {
    case "image":
        return ImageComponent(id: id, workflowName: workflowName, workflowId: workflowId, dict: dict)
    case "package":
        return PackageComponent(id: id, workflowName: workflowName, workflowId: workflowId, dict: dict)
    case "included_workflow":
        return IncludedWorkflowComponent(id: id, workflowName: workflowName, workflowId: workflowId, dict: dict)
    case "computer_name":
        return ComputerNameComponent(id: id, workflowName: workflowName, workflowId: workflowId, dict: dict)
    case "eraseVolume":
        return EraseVolumeComponent(id: id, workflowName: workflowName, workflowId: workflowId, dict: dict)
    case "script":
        return ScriptComponent(id: id, workflowName: workflowName, workflowId: workflowId, dict: dict)
    case "localize":
        return LocalizationComponent(id: id, workflowName: workflowName, workflowId: workflowId, dict: dict)
    default:
        return nil
    }
}