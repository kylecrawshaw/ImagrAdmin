//
//  ImageComponentViewController.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/14/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Cocoa

class LocalizationComponentViewController: NSViewController {

    @IBOutlet weak var countryCodeDropdown: NSPopUpButton!
    @IBOutlet weak var kbLayoutNameDropdown: NSPopUpButton!
    @IBOutlet weak var languagesDropdown: NSPopUpButton!
    @IBOutlet weak var timezoneDropdown: NSPopUpButton!
    
    var component: LocalizationComponent?
    
    override func viewDidLoad() {
        
        if countryCodeDropdown.itemArray.count == 0 {
            let countryCodes = LocalizationManager.countryCodes()
            let countryCodesSorted = countryCodes.sort { $0 < $1 }
            countryCodeDropdown.addItemsWithTitles(countryCodesSorted)
        }
        
    }
    
    override func viewWillAppear() {
        super.viewDidAppear()
        component = ImagrConfigManager.sharedManager.getComponent(self.identifier!) as? LocalizationComponent
        
        let countryCode = component!.countryCode
        if countryCode != nil && countryCodeDropdown.selectedItem!.title != "" {
            countryCodeDropdown.selectItemWithTitle(countryCode!)
            let languages = LocalizationManager.getLanguages(countryCode!)
            updateDropdown(languagesDropdown, dropdownItems: languages, selectedItem: component!.language)
            
            let timezones = LocalizationManager.getTimezones(countryCode!)
            updateDropdown(timezoneDropdown, dropdownItems: timezones, selectedItem: component!.timezone)
            
            let keyboardLayouts = LocalizationManager.getInputSources(countryCode!)
            updateDropdown(kbLayoutNameDropdown, dropdownItems: keyboardLayouts, selectedItem: component!.keyboardLayoutName)
        }
    }
    
    override func viewDidDisappear() {
        if kbLayoutNameDropdown.selectedItem != nil {
            component!.keyboardLayoutName = kbLayoutNameDropdown.selectedItem!.title
        }
        
        if kbLayoutNameDropdown.selectedItem != nil {
            component!.keyboardLayoutId = LocalizationManager.getKeyboardLayoutId(kbLayoutNameDropdown.selectedItem!.title)
        }
        
        if timezoneDropdown.selectedItem != nil {
            component!.timezone = timezoneDropdown.selectedItem!.title
        }
        
        if languagesDropdown.selectedItem != nil {
            component!.language = languagesDropdown.selectedItem!.title
        }
        
        if countryCodeDropdown.selectedItem != nil {
            component!.countryCode = countryCodeDropdown.selectedItem!.title
        }
        
        component!.notifyUpdateTable()
    }
    
    @IBAction func okButtonClicked(sender: AnyObject) {
        component!.closeComponentPanel()
    }
    
    
    @IBAction func countryCodeChanged(sender: AnyObject) {
        let selectedCountryCode = countryCodeDropdown.selectedItem!.title
        let languages = LocalizationManager.getLanguages(selectedCountryCode)
        updateDropdown(languagesDropdown, dropdownItems: languages, selectedItem: nil)
        
        let timezones = LocalizationManager.getTimezones(selectedCountryCode)
        updateDropdown(timezoneDropdown, dropdownItems: timezones, selectedItem: nil)
        
        let keyboardLayouts = LocalizationManager.getInputSources(selectedCountryCode)
        updateDropdown(kbLayoutNameDropdown, dropdownItems: keyboardLayouts, selectedItem: nil)
    }
    
    func updateDropdown(dropdown: NSPopUpButton, dropdownItems: NSArray, selectedItem: String?) {
        dropdown.removeAllItems()
        dropdown.addItemWithTitle("")
        dropdown.addItemsWithTitles(dropdownItems as! [String])
        dropdown.enabled = true
        
        if selectedItem != nil {
            dropdown.selectItemWithTitle(selectedItem!)
        }
    }
    
    
}
