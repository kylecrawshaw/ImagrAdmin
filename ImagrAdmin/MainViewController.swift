//
//  MainViewController.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/9/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

import Cocoa
import Carbon

let tempDir = NSTemporaryDirectory() as String

class MainViewController: NSViewController, NSWindowDelegate {

    // Main view objects
    @IBOutlet weak var mainWindow: NSWindow!
    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var backgroundImageField: NSTextField!
    @IBOutlet weak var passwordField: NSTextField!
    @IBOutlet weak var changePasswordButton: NSButton!
    @IBOutlet weak var autorunDropdown: NSPopUpButton!
    @IBOutlet weak var defaultDropdown: NSPopUpButton!
    
    // Validation view objects
    @IBOutlet weak var validateView: NSView!
    @IBOutlet var validateTextField: NSTextView!
    @IBOutlet weak var validateSpinner: NSProgressIndicator!
    @IBOutlet weak var validateOkButton: NSButton!
    @IBOutlet weak var skipValidateButton: NSButton!
    
    // Welcome view objects
    @IBOutlet weak var welcomeView: NSView!
    
    
    let openPanel: NSOpenPanel = NSOpenPanel()
    let savePanel: NSSavePanel = NSSavePanel()
    
    private var task: NSTask?
    private var selectedConfigPath: String!

    override func viewDidAppear() {
        super.viewDidAppear()
        // Setup observer to get notified to update the tableView.
        // This will occur when content from a workflow window is updated
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateView(_:)), name:"UpdateWorkflowTableView", object: nil)
        
        // Display the welcomeView the the ImagrConfigManager singleton
        // has not been configured
        if !ImagrConfigManager.sharedManager.hasLoaded {
            mainWindow.contentView = welcomeView
        }
    }
    
    // remove observers when the view isn't visible
    override func viewDidDisappear() {
        super.viewDidDisappear()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mainWindow.delegate = self
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.target = self
        let registeredTypes: [String] = [NSStringPboardType]
        tableView.registerForDraggedTypes(registeredTypes)
    }

    
    @IBAction func quitApp(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }


    @IBAction func createNewConfig(sender: AnyObject) {
        ImagrConfigManager.sharedManager.loadConfig()
        updateView(self)
        mainWindow.contentView = mainView
    }
    

    
    @IBAction func displayOpenPanel(sender: AnyObject) {
        openPanel.message = "Locate Imagr Config. Must be a .plist"
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["plist"]
        openPanel.beginSheetModalForWindow(mainWindow, completionHandler: openPanelDidClose)
    }
    
    func openPanelDidClose(response: NSModalResponse) {
        if response != 0 {
            selectedConfigPath = openPanel.URL!.path!
            NSLog("User selected path \(selectedConfigPath)")
            
            // Check if the path selected is a directory or
            var isDir: ObjCBool = false
            NSFileManager.defaultManager().fileExistsAtPath(openPanel.URL!.path!, isDirectory: &isDir)
            
            if NSFileManager.defaultManager().fileExistsAtPath(selectedConfigPath) {
                NSLog("Need to validate \(selectedConfigPath)")
                displayValidateView(selectedConfigPath)
            }
            ImagrConfigManager.sharedManager.loadConfig(selectedConfigPath)
            updateView(self)
        } else {
            mainWindow.contentView = welcomeView
        }
    }
    
    
    @IBAction func saveAll(sender: AnyObject) {
        var visibleWindows: Bool = false
        for workflow in ImagrConfigManager.sharedManager.workflows {
            if workflow.workflowWindow?.visible == true {
                visibleWindows = true
                break
            }
        }
        if visibleWindows {
            let a = NSAlert()
            a.messageText = "All workflow windows must be closed before saving"
            mainWindow.makeKeyAndOrderFront(self)
            a.beginSheetModalForWindow(mainWindow, completionHandler: nil)
        } else {
            saveConfig()
        }
    }

    @IBAction func removeWorkflow(sender: AnyObject) {
        if tableView.selectedRow >= 0 {
            ImagrConfigManager.sharedManager.workflows.removeAtIndex(tableView.selectedRow)
            updateView(self)
        }
    }

    func updateView(sender: AnyObject?) {
        NSLog("Updating config view")
        if ImagrConfigManager.sharedManager.hasLoaded == false {
            NSLog("Unable to load config view. ImagrConfigManager.sharedManager has not been initialized")
            return
        }

        let imagrPassword = ImagrConfigManager.sharedManager.password
        if imagrPassword != nil {
            passwordField.placeholderString = "Hashed password is already set"
            passwordField.enabled = false
            changePasswordButton.hidden = false
        } else {
            passwordField.placeholderString = nil
            passwordField.enabled = true
            changePasswordButton.hidden = true
        }

        let workflowTitles = ImagrConfigManager.sharedManager.workflowTitles()

        let bgImage = ImagrConfigManager.sharedManager.backgroundImage
        if backgroundImageField.stringValue == "" && bgImage != nil {
            backgroundImageField.stringValue = bgImage!
        }

        let autorunWorkflow = ImagrConfigManager.sharedManager.autorunWorkflow
        let selectedAutorun = autorunDropdown.selectedItem
        autorunDropdown.removeAllItems()
        autorunDropdown.addItemWithTitle("")
        autorunDropdown.addItemsWithTitles(workflowTitles)
        if selectedAutorun == nil && autorunWorkflow != nil {
            autorunDropdown.selectItemWithTitle(autorunWorkflow!)
        } else if selectedAutorun != nil {
            autorunDropdown.selectItemWithTitle(selectedAutorun!.title)
        }

        let defaultWorkflow = ImagrConfigManager.sharedManager.defaultWorkflow
        let selectedDefault = defaultDropdown.selectedItem
        defaultDropdown.removeAllItems()
        defaultDropdown.addItemWithTitle("")
        defaultDropdown.addItemsWithTitles(workflowTitles)
        if selectedDefault == nil && defaultWorkflow != nil {
            defaultDropdown.selectItemWithTitle(defaultWorkflow!)
        } else if selectedDefault != nil {
            defaultDropdown.selectItemWithTitle(selectedDefault!.title)
        }


        tableView.reloadData()
    }

    @IBAction func terminateValidationTask(sender: AnyObject) {
        task!.terminate()
    }


    @IBAction func addWorkflow(sender: AnyObject) {
        let workflow = ImagrWorkflowManager(name: "", description: "", components: [])
        ImagrConfigManager.sharedManager.workflows.append(workflow)
        workflow.displayWorkflowWindow()
    }

    @IBAction func changePasswordClicked(sender: AnyObject) {
        passwordField.stringValue = ""
        passwordField.enabled = true
        changePasswordButton.enabled = false
    }



    @IBAction func saveButtonClicked(sender: AnyObject) {
        saveConfig()
        let saveAlert = NSAlert()
        saveAlert.informativeText = "\(ImagrConfigManager.sharedManager.imagrConfigPath!)"
        saveAlert.messageText = "Imagr config successfully saved!"
        saveAlert.beginSheetModalForWindow(mainWindow, completionHandler: nil)
    }

    @IBAction func validateButtonClicked(sender: AnyObject) {
        let tempPlistPath = "\(tempDir)imagr_config.plist"
        saveConfig(tempPlistPath)
        displayValidateView(tempPlistPath)
    }

    func updateConfig() {
        if passwordField.enabled && passwordField.stringValue != "" {
            ImagrConfigManager.sharedManager.password = passwordField.stringValue.sha512()
            passwordField.enabled = false
            changePasswordButton.enabled = true
            passwordField.stringValue = ""
            NSLog("Password was updated")
        }

        if backgroundImageField.stringValue == "" {
            ImagrConfigManager.sharedManager.backgroundImage = nil
        } else {
            ImagrConfigManager.sharedManager.backgroundImage = backgroundImageField.stringValue
        }

        if defaultDropdown.selectedItem == nil || defaultDropdown.selectedItem!.title == "" {
            ImagrConfigManager.sharedManager.defaultWorkflow = nil
        } else {
            ImagrConfigManager.sharedManager.defaultWorkflow = defaultDropdown.selectedItem!.title
        }

        if autorunDropdown.selectedItem == nil || autorunDropdown.selectedItem!.title == "" {
            ImagrConfigManager.sharedManager.autorunWorkflow = nil
        } else {
            ImagrConfigManager.sharedManager.autorunWorkflow = autorunDropdown.selectedItem!.title
        }
        NSLog("Updated ImagrConfigManager from MainViewController")
    }

    func saveConfig() {
        updateConfig()
        if ImagrConfigManager.sharedManager.hasLoaded == true && ImagrConfigManager.sharedManager.imagrConfigPath == nil {
            savePanel.allowedFileTypes = ["plist"]
            savePanel.beginSheetModalForWindow(mainWindow, completionHandler: savePanelDidClose)
        } else {
            ImagrConfigManager.sharedManager.save()
            NSLog("Imagr config saved to path: \(ImagrConfigManager.sharedManager.imagrConfigPath!)")
            let saveAlert = NSAlert()
            saveAlert.informativeText = "\(ImagrConfigManager.sharedManager.imagrConfigPath!)"
            saveAlert.messageText = "Imagr config successfully saved!"
            saveAlert.beginSheetModalForWindow(mainWindow, completionHandler: nil)
        }
    }
    
    func savePanelDidClose(response: NSModalResponse) {
        if response == 1 {
            ImagrConfigManager.sharedManager.imagrConfigPath = savePanel.URL!.path!
            saveConfig()
        }
    }

    func saveConfig(path: String) {
        updateConfig()
        ImagrConfigManager.sharedManager.save(path)
        NSLog("Imagr config saved to path: \(path)")
    }


    @IBAction func validateOkClicked(sender: AnyObject) {
        mainWindow.contentView = mainView
    }


    func displayValidateView(plistPath: String) {
        // this should happen anytime this function is called.
        // the task will be set to nil everytime it terminates
        if task == nil {
            task = NSTask()
        }
        
        // set up the task with the correct executable and path to validateplist.py
        task!.launchPath = "/usr/bin/python"
        let validatePlistPath = NSBundle.mainBundle().pathForResource("validateplist", ofType: "py")!
        task!.arguments = [validatePlistPath, plistPath]

        // set up a Pipe to handle stdout from the task
        let pipe = NSPipe()
        task!.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()

        // observer for when there is output available from the validateplist path
        var obs1 : NSObjectProtocol!
        obs1 = NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: outHandle, queue: nil) {
            notification -> Void in
            let data = outHandle.availableData
            
            // make sure there is data or remove the observer
            if data.length > 0 {
                if let str = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                    
                    // split the output by new line separators.
                    // each line should be a message from validateplist
                    let lines = str.componentsSeparatedByString("\n")
                    for line in lines {
                        // format each message with the appropriate colors
                        self.validateTextField.textStorage?.appendAttributedString(formatMessageString(line))
                    }
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                NSNotificationCenter.defaultCenter().removeObserver(obs1)
            }
        }

        // observer used to receive terminate notification. stops all progress and disables the necessary buttons
        var obs2 : NSObjectProtocol!
        obs2 = NSNotificationCenter.defaultCenter().addObserverForName(NSTaskDidTerminateNotification, object: task, queue: nil) {
            notification -> Void in
            NSLog("Validation task terminated")
            self.validateSpinner.stopAnimation(self)
            self.validateSpinner.hidden = true
            self.validateOkButton.enabled = true
            self.skipValidateButton.enabled = false
            NSNotificationCenter.defaultCenter().removeObserver(obs2)
            
            // make sure the task is nil so that when this function is called a new task is created
            self.task = nil
        }
        
        // switch the view, start progress spinner and enable necessary buttons
        mainWindow.contentView = validateView
        validateSpinner.startAnimation(self)
        validateSpinner.hidden = false
        validateOkButton.enabled = false
        skipValidateButton.enabled = true
        
        // launch the task with GCD after a half second delay
        let timeDelay = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(timeDelay, dispatch_get_main_queue()) {
            // Make sure text is all black for the first line
            let startOutput = NSAttributedString(string: "Running validateplist...\n\n", attributes: [NSForegroundColorAttributeName: NSColor.blackColor()])
            self.validateTextField.textStorage?.appendAttributedString(startOutput)
            self.task!.launch()
        }
    }


}


// handles the datasource methods for the workflow tableView
extension MainViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        // get workflow array from
        let workflows = ImagrConfigManager.sharedManager.workflows
        if workflows != nil {
            return workflows.count ?? 0
        } else {
            return 0
        }
    }
}



extension MainViewController: NSTableViewDelegate {

    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var text: String = ""
        var cellIdentifier: String = ""


        let workflow = ImagrConfigManager.sharedManager.workflows[row]
        if tableColumn == tableView.tableColumns[0] {

            text = workflow.name
            cellIdentifier = "NameCellID"

        } else if tableColumn == tableView.tableColumns[1] {

            text = workflow.description
            cellIdentifier = "DescriptionCellID"

        } else if tableColumn == tableView.tableColumns[2] {

            text = String(workflow.hidden ?? false)
            cellIdentifier = "HiddenCellID"

        } else if tableColumn == tableView.tableColumns[3] {

            text = String(workflow.blessTarget ?? true)
            cellIdentifier = "BlessCellID"

        } else if tableColumn == tableView.tableColumns[4] {

            text = String(workflow.restartAction ?? "none")
            cellIdentifier = "RestartCellID"

        }
        if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }

    @IBAction func tableViewDoubleClick(sender: AnyObject) {
        guard tableView.selectedRow >= 0 , let workflow = ImagrConfigManager.sharedManager.workflows?[tableView.selectedRow] else {
            return
        }
        workflow.displayWorkflowWindow()

    }

    // DRAG AND DROP METHODS
    func tableView(aTableView: NSTableView, writeRowsWithIndexes rowIndexes: NSIndexSet, toPasteboard pboard: NSPasteboard) -> Bool {
        if (aTableView == tableView) {
            let data:NSData = NSKeyedArchiver.archivedDataWithRootObject(rowIndexes)
            let registeredTypes:[String] = [NSStringPboardType]
            pboard.declareTypes(registeredTypes, owner: self)
            pboard.setData(data, forType: NSStringPboardType)
            return true
        } else {
            return false
        }
    }

    func tableView(aTableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation operation: NSTableViewDropOperation) -> NSDragOperation {

        if operation == .Above {
            return .Move
        }
        return .Every

    }

    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool {
        let data:NSData = info.draggingPasteboard().dataForType(NSStringPboardType)!
        let rowIndexes:NSIndexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSIndexSet

        if ((info.draggingSource() as! NSTableView == tableView) && (tableView == tableView)) {
            let value = ImagrConfigManager.sharedManager.workflows[rowIndexes.firstIndex]
            ImagrConfigManager.sharedManager.workflows.removeAtIndex(rowIndexes.firstIndex)

            if (row > ImagrConfigManager.sharedManager.workflows.count){
                ImagrConfigManager.sharedManager.workflows.insert(value, atIndex: row-1)
            } else {
                ImagrConfigManager.sharedManager.workflows.insert(value, atIndex: row)
            }
            tableView.reloadData()
            return true
        } else {
            return false
        }
    }
}
