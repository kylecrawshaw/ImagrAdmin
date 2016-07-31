//
//  ImageComponentViewController.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/14/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Cocoa

class ComputerNameViewController: NSViewController {
    
    
    @IBOutlet weak var useSerialCheckbox: NSButton!
    @IBOutlet weak var autoCheckbox: NSButton!
    
    var component: ComputerNameComponent?
    
    override func viewWillAppear() {
        super.viewDidAppear()
        component = ImagrConfigManager.sharedManager.getComponent(self.identifier!) as? ComputerNameComponent
        
        if component!.useSerial == true {
            useSerialCheckbox.state = 1
        } else {
            useSerialCheckbox.state = 0
        }
        
        if component!.auto == true {
            autoCheckbox.state = 1
        } else {
            autoCheckbox.state = 0
        }
        
    }
    
    override func viewDidDisappear() {
        if useSerialCheckbox.state == 1 {
            component!.useSerial = true
        } else {
            component!.useSerial = false
        }
        
        if autoCheckbox.state == 1 {
            component!.auto = true
        } else {
            component!.auto = false
        }
        component!.notifyUpdateTable()
    }
    
    @IBAction func okButtonClicked(sender: AnyObject) {
        component!.closeComponentPanel()
    }

    
}
