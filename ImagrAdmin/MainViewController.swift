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

class MainViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var mainWindow: NSWindow!
    @IBOutlet weak var mainView: NSView!
    @IBOutlet weak var backgroundImageField: NSTextField!
    @IBOutlet weak var passwordField: NSTextField!
    @IBOutlet weak var changePasswordButton: NSButton!
    @IBOutlet weak var autorunDropdown: NSPopUpButton!
    @IBOutlet weak var defaultDropdown: NSPopUpButton!
    @IBOutlet var validateTextField: NSTextView!
    @IBOutlet weak var validateSpinner: NSProgressIndicator!
    @IBOutlet weak var validateOkButton: NSButton!
    @IBOutlet weak var validateView: NSView!
    @IBOutlet weak var skipValidateButton: NSButton!

    let openPanel: NSOpenPanel = NSOpenPanel()
    private var task: NSTask?

    private var selectedConfigPath: String!
//    private var validationOutput: String!
//    private var validationOutput: NSMutableAttributedString?

    override func viewDidAppear() {
        super.viewDidAppear()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTableNotificationReceived(_:)), name:"UpdateWorkflowTableView", object: nil)

        if ImagrConfigManager.sharedManager.imagrConfigPath == nil {
            displayOpenPanel()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.target = self
        let registeredTypes: [String] = [NSStringPboardType]
        tableView.registerForDraggedTypes(registeredTypes)
    }


    @IBAction func removeWorkflow(sender: AnyObject) {
        if tableView.selectedRow >= 0 {
            ImagrConfigManager.sharedManager.workflows.removeAtIndex(tableView.selectedRow)
            updateView()
        }
    }

    func updateView() {
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

    func updateTableNotificationReceived(sender: AnyObject) {
        updateView()
    }


    func displayOpenPanel() {
        openPanel.message = "Locate imagr_config.plist or a directory to create imagr_config.plist"
        openPanel.allowsMultipleSelection = false
        openPanel.allowedFileTypes = ["plist"]
        openPanel.canChooseDirectories = true
        openPanel.beginSheetModalForWindow(mainWindow, completionHandler: openPanelDidClose)
    }

    func openPanelDidClose(response: NSModalResponse) {
        if response != 0 {
            selectedConfigPath = openPanel.URL!.path!
            NSLog("User selected path \(selectedConfigPath)")

            // Check if the path selected is a directory or
            var isDir: ObjCBool = false
            NSFileManager.defaultManager().fileExistsAtPath(openPanel.URL!.path!, isDirectory: &isDir)

            if isDir {
                selectedConfigPath = "\(selectedConfigPath)/imagr_config.plist"
            }

            if NSFileManager.defaultManager().fileExistsAtPath(selectedConfigPath) {
                NSLog("Need to validate \(selectedConfigPath)")
                displayValidateView(selectedConfigPath)
            }
            ImagrConfigManager.sharedManager.loadConfig(selectedConfigPath)
            updateView()
        } else {
            NSApplication.sharedApplication().terminate(self)
        }
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

        if defaultDropdown.selectedItem!.title == "" {
            ImagrConfigManager.sharedManager.defaultWorkflow = nil
        } else {
            ImagrConfigManager.sharedManager.defaultWorkflow = defaultDropdown.selectedItem!.title
        }

        if autorunDropdown.selectedItem!.title == "" {
            ImagrConfigManager.sharedManager.autorunWorkflow = nil
        } else {
            ImagrConfigManager.sharedManager.autorunWorkflow = autorunDropdown.selectedItem!.title
        }
        NSLog("Updated ImagrConfigManager from MainViewController")
    }

    func saveConfig() {
        updateConfig()
        ImagrConfigManager.sharedManager.save()
        NSLog("Imagr config saved to path: \(ImagrConfigManager.sharedManager.imagrConfigPath!)")
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
        if task == nil {
            task = NSTask()
        }
        task!.launchPath = "/usr/bin/python"
        let validatePlistPath = NSBundle.mainBundle().pathForResource("validateplist", ofType: "py")!
        task!.arguments = [validatePlistPath, plistPath]

        let pipe = NSPipe()
        task!.standardOutput = pipe
        let outHandle = pipe.fileHandleForReading
        outHandle.waitForDataInBackgroundAndNotify()

        var obs1 : NSObjectProtocol!
        obs1 = NSNotificationCenter.defaultCenter().addObserverForName(NSFileHandleDataAvailableNotification, object: outHandle, queue: nil) {
            notification -> Void in
            let data = outHandle.availableData
            if data.length > 0 {
                if let str = NSString(data: data, encoding: NSUTF8StringEncoding) as? String {
                    let lines = str.componentsSeparatedByString("\n")

                    for line in lines {
                        self.validateTextField.textStorage?.appendAttributedString(formatMessageString(line))
                    }
                }
                outHandle.waitForDataInBackgroundAndNotify()
            } else {
                NSNotificationCenter.defaultCenter().removeObserver(obs1)
            }
        }

        var obs2 : NSObjectProtocol!
        obs2 = NSNotificationCenter.defaultCenter().addObserverForName(NSTaskDidTerminateNotification, object: task, queue: nil) {
            notification -> Void in
            NSLog("Validation task terminated")
            self.validateSpinner.stopAnimation(self)
            self.validateSpinner.hidden = true
            self.validateOkButton.enabled = true
            self.skipValidateButton.enabled = false
            NSNotificationCenter.defaultCenter().removeObserver(obs2)
            self.task = nil
        }
        mainWindow.contentView = validateView
        validateSpinner.startAnimation(self)
        validateSpinner.hidden = false
        validateOkButton.enabled = false
        skipValidateButton.enabled = true
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * Double(NSEC_PER_SEC)))
        dispatch_after(popTime, dispatch_get_main_queue()) {
            let startOutput = NSAttributedString(string: "Running validateplist...\n\n", attributes: [NSForegroundColorAttributeName: NSColor.blackColor()])
            self.validateTextField.textStorage?.appendAttributedString(startOutput)
            self.task!.launch()
        }
    }


}



extension MainViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
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
            text = String(workflow.hidden)
            cellIdentifier = "HiddenCellID"
        } else if tableColumn == tableView.tableColumns[3] {
            text = String(workflow.blessTarget)
            cellIdentifier = "BlessCellID"
        } else if tableColumn == tableView.tableColumns[4] {
            text = String(workflow.restartAction)
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
