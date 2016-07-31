//
//  IncludedWorkflowViewController.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/15/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Cocoa

class IncludedWorkflowViewController: NSViewController {

    @IBOutlet var scriptField: NSTextView!
    @IBOutlet weak var includedWorkflowDropdown: NSPopUpButton!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet var mainView: NSView!
    @IBOutlet var dropdownView: NSView!
    @IBOutlet var scriptView: NSView!
    @IBOutlet weak var scriptRadioButton: NSButton!
    @IBOutlet weak var selectRadioButton: NSButton!
    
    var component: IncludedWorkflowComponent?
    var contentFrameOrigin: CGPoint!
    var originalWindowFrame: CGRect!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentFrameOrigin = contentView.frame.origin
    }
    
    override func viewWillAppear() {
        super.viewDidAppear()
        component = ImagrConfigManager.sharedManager.getComponent(self.identifier!) as? IncludedWorkflowComponent
        let viewIdentifierSplit = self.identifier!.characters.split{$0 == "-"}.map(String.init)
        let workflowName = viewIdentifierSplit[0]
        
        var workflowTitles: [String] = []
        for workflow in ImagrConfigManager.sharedManager.workflows! {
            if workflow.name != workflowName {
                workflowTitles.append(workflow.name)
            }
        }
        
        includedWorkflowDropdown!.removeAllItems()
        includedWorkflowDropdown!.addItemsWithTitles(workflowTitles)
        if component!.script != nil {
            scriptField!.string = component!.script
        }
        
        if component!.includedWorkflow != nil && component!.script == nil {
            includedWorkflowDropdown!.selectItemWithTitle(component!.includedWorkflow!)
            scriptRadioButton.state = 0
            selectRadioButton.state = 1
        } else if component!.script != nil {
            scriptRadioButton.state = 1
            selectRadioButton.state = 0
        }
        else {
            includedWorkflowDropdown!.selectItemAtIndex(0)
            scriptRadioButton.state = 0
            selectRadioButton.state = 1
        }

        if originalWindowFrame == nil {
            originalWindowFrame = component!.componentWindow!.frame
        }
        updateView(self)
        
    }
    
    override func viewDidDisappear() {
        if selectRadioButton.state == 1 {
            component!.includedWorkflow = includedWorkflowDropdown!.titleOfSelectedItem
        } else {
            component!.script = scriptField.string
        }
        
        component!.notifyUpdateTable()
    }
    
    @IBAction func updateView(sender: AnyObject) {
        var newView: NSView!
        if selectRadioButton.state == 1 {
            newView = dropdownView
        } else {
            newView = scriptView
        }
        
        let workflow = ImagrConfigManager.sharedManager.getWorkflow(component!.workflowName)
        workflow!.workflowWindow!.frame.origin.x
        // Adjust the window size
        let newHeight = newView.frame.height + originalWindowFrame.height
        
        let newSize = NSMakeSize(originalWindowFrame.width, newHeight)
        mainView.setFrameSize(newSize)
        let newOriginX = workflow!.workflowWindow!.frame.origin.x + ((workflow!.workflowWindow!.contentView!.frame.size.width - newSize.width) / 2)
        let newOriginY = (workflow!.workflowWindow!.contentView!.frame.size.height - newSize.height) + workflow!.workflowWindow!.frame.origin.y
        
        let newOrigin = CGPoint(x: newOriginX, y: newOriginY)
        let newFrame = CGRect(origin: newOrigin, size: newSize)
        
        
        component!.componentWindow!.setFrame(newFrame, display: true, animate: false)
        
        
        newView.setFrameOrigin(contentFrameOrigin)
        
        var originalView: NSView!
        for subview in mainView!.subviews {
            if subview.identifier! == "placeholder" {
                originalView = contentView
                break
            } else if subview.identifier! == "script" {
                originalView = scriptView
                break
            } else if subview.identifier! == "select" {
                originalView = dropdownView
                break
            }
        }
        mainView!.replaceSubview(originalView, with: newView)
    }
    
    @IBAction func okButtonClicked(sender: AnyObject) {
        component!.closeComponentPanel()
    }
    
}
