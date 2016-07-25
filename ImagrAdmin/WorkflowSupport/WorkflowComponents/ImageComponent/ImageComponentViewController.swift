//
//  ImageComponentViewController.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/14/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Cocoa

class ImageComponentViewController: NSViewController {

    
    @IBOutlet weak var imageURLField: NSTextField!
    @IBOutlet weak var verifyImageCheckbox: NSButton!
    
    var component: ImageComponent?
    
    override func viewWillAppear() {
        super.viewDidAppear()
        component = ImagrConfigManager.sharedManager.getComponent(self.identifier!) as? ImageComponent
        imageURLField.stringValue = component!.URL
        if component!.verify == false {
            verifyImageCheckbox.state = 0
        } else {
            verifyImageCheckbox.state = 1
        }
        
    }
    
    @IBAction func okButtonClicked(sender: AnyObject) {
        component!.URL = imageURLField.stringValue
        if verifyImageCheckbox.state == 0 {
            component!.verify = false
        } else {
            component!.verify = true
        }
        component!.notifyUpdateTable()
    }
    
    
    
    
}
