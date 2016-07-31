//
//  ImageComponentViewController.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/14/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Cocoa

class EraseVolumeViewController: NSViewController {
    
    @IBOutlet weak var volumeNameField: NSTextField!
    @IBOutlet weak var volumeFormatField: NSTextField!

    
    var component: EraseVolumeComponent?
    
    override func viewWillAppear() {
        super.viewDidAppear()
        component = ImagrConfigManager.sharedManager.getComponent(self.identifier!) as? EraseVolumeComponent
        volumeNameField.stringValue = component!.volumeName
        volumeFormatField.stringValue = component!.volumeFormat
    }
    
    override func viewDidDisappear() {
        component!.volumeName = volumeNameField.stringValue
        component!.volumeFormat = volumeFormatField.stringValue
        component!.notifyUpdateTable()
    }
    
    @IBAction func okButtonClicked(sender: AnyObject) {
        component!.closeComponentPanel()
    }

    
}
