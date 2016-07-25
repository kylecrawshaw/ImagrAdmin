//
//  PackageComponentViewController.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/15/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Cocoa

class ScriptComponentViewController: NSViewController {
    
    @IBOutlet weak var scriptURLField: NSTextField!
    @IBOutlet var scriptContent: NSTextView!
    @IBOutlet weak var firstBootCheckbox: NSButton!
    @IBOutlet weak var contentView: NSView!
    @IBOutlet var mainView: NSView!
    @IBOutlet var scriptURLView: NSView!
    @IBOutlet var bottomView: NSView!
    @IBOutlet var scriptView: NSView!
    @IBOutlet weak var manualRadioButton: NSButton!
    @IBOutlet weak var urlRadioButton: NSButton!
    
    var component: ScriptComponent?
    var contentFrameOrigin: CGPoint!
    var originalWindowFrame: CGRect!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentFrameOrigin = contentView.frame.origin
    }
    
    override func viewWillAppear() {
        super.viewDidAppear()
        component = ImagrConfigManager.sharedManager.getComponent(self.identifier!) as? ScriptComponent
        
        if component!.content != nil {
            scriptContent.string = component!.content!
            manualRadioButton.state = 1
            urlRadioButton.state = 0
        } else if component!.URL != nil {
            scriptURLField.stringValue = component!.URL!
            manualRadioButton.state = 0
            urlRadioButton.state = 1
        } else {
            scriptURLField.stringValue = ""
            manualRadioButton.state = 0
            urlRadioButton.state = 1
        }

        if component!.firstBoot == false {
            firstBootCheckbox.state = 0
        } else {
            firstBootCheckbox.state = 1
        }
        
        if originalWindowFrame == nil {
            originalWindowFrame = component!.componentWindow!.frame
        }
        updateView()
        
    }
    
    func updateView() {
        var newView: NSView!
        if urlRadioButton.state == 1{
            newView = scriptURLView
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
            } else if subview.identifier! == "url" {
                originalView = scriptURLView
                break
            }
        }
        mainView!.replaceSubview(originalView, with: newView)
        
        
    }
    
    @IBAction func okButtonClicked(sender: AnyObject) {
        
        if manualRadioButton.state == 1 {
            component!.content = scriptContent.string
            component!.URL = nil
        } else {
            component!.content = nil
            component!.URL = scriptURLField.stringValue
        }
        
        
        if firstBootCheckbox.state == 0 {
            component!.firstBoot = false
        } else {
            component!.firstBoot = true
        }
        
        component!.notifyUpdateTable()
    }
    
    @IBAction func toggleScriptType(sender: NSButton) {
        NSLog("User clicked \"From URL\"")
        updateView()
    }
    
}
