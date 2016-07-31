//
//  PackageComponentViewController.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/15/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Cocoa

class PackageComponentViewController: NSViewController {
    
    @IBOutlet weak var packageURLField: NSTextField!
    @IBOutlet weak var firstBootCheckbox: NSButton!
    
    var component: PackageComponent?
    
    override func viewWillAppear() {
        super.viewDidAppear()
        component = ImagrConfigManager.sharedManager.getComponent(self.identifier!) as? PackageComponent
        packageURLField.stringValue = component!.URL
        if component!.firstBoot == false {
            firstBootCheckbox.state = 0
        } else {
            firstBootCheckbox.state = 1
        }
        
    }
    
    override func viewDidDisappear() {
        component!.URL = packageURLField.stringValue
        if firstBootCheckbox.state == 0 {
            component!.firstBoot = false
        } else {
            component!.firstBoot = true
        }
        component!.notifyUpdateTable()
    }
    
    @IBAction func okButtonClicked(sender: AnyObject) {
        component!.closeComponentPanel()
    }
    
}
