//
//  BaseComponentViewController.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/15/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Cocoa

public class BaseComponentViewController: NSViewController {
    
    internal var workflowName: String?
    internal var workflowWindow: NSWindow?

    override public func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func configure(workflowWindow: NSWindow!) {
        self.workflowWindow = workflowWindow
    }
    
}
