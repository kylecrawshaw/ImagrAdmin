//
//  WorkflowViewController.swift
//  ImagrManager
//
//  Created by Kyle Crawshaw on 7/10/16.
//  Copyright © 2016 Kyle Crawshaw. All rights reserved.
//

//import Foundation
import Cocoa

class WorkflowViewController: NSViewController {

    @IBOutlet weak var label: NSTextField!
    @IBOutlet weak var nameField: NSTextField!
    @IBOutlet weak var descriptionField: NSTextField!
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var selectComponentPanel: NSPanel!
    @IBOutlet weak var componentDropdown: NSPopUpButton!
    @IBOutlet var workflowWindow: NSWindow!
    @IBOutlet weak var blessCheckBox: NSButton!
    @IBOutlet weak var restartActionDropdown: NSPopUpButton!
    @IBOutlet weak var hiddenCheckbox: NSButton!
    
    var workflow: ImagrWorkflowManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        workflow = ImagrConfigManager.sharedManager.getWorkflow(self.identifier)
        
        let notificationName = "UpdateTableView-\(workflow!.workflowID!)"
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateTableNotificationReceived(_:)), name:notificationName, object: nil)
        
        nameField.stringValue = workflow!.name
        descriptionField.stringValue = workflow!.description
        
        if workflow!.restartAction != nil {
            restartActionDropdown.selectItemWithTitle(workflow!.restartAction)
        }
        
        if workflow!.blessTarget != nil && workflow!.blessTarget == false {
            blessCheckBox.state = 0
        } else {
            blessCheckBox.state = 1
        }
        
        if workflow!.hidden != nil && workflow!.hidden == true {
            hiddenCheckbox.state = 1
        } else {
            hiddenCheckbox.state = 0
        }
        
        tableView.setDelegate(self)
        tableView.setDataSource(self)
        tableView.target = self
        let registeredTypes: [String] = [NSStringPboardType]
        tableView.registerForDraggedTypes(registeredTypes)
    }
    
    func updateTableNotificationReceived(sender: AnyObject) {
        NSLog("Received notification to update workflow with ID: \(workflow?.workflowID)")
        tableView.reloadData()
    }
    
    override func viewDidAppear() {
        tableView.reloadData()
    }

    
    override func viewDidDisappear() {
        let workflowTitles = ImagrConfigManager.sharedManager.workflowTitles()
        if workflowTitles.contains(nameField.stringValue) && workflow!.name != nameField.stringValue{
            let nameAlert = NSAlert()
            nameAlert.alertStyle = NSAlertStyle.CriticalAlertStyle
            nameAlert.messageText = "This name is already assigned to another workflow"
            nameAlert.informativeText = "Workflow names must be unique"
            nameAlert.beginSheetModalForWindow(workflowWindow!, completionHandler: nil)
        } else {
            workflow!.name = nameField.stringValue
            workflow!.description = descriptionField.stringValue
            workflow!.restartAction = restartActionDropdown.selectedItem!.title
            
            if blessCheckBox.state == 0 {
                workflow!.blessTarget = false
            } else {
                workflow!.blessTarget = true
            }
            
            if hiddenCheckbox.state == 1 {
                workflow!.hidden = true
            } else {
                workflow!.hidden = false
            }
            NSNotificationCenter.defaultCenter().postNotificationName("UpdateWorkflowTableView", object: nil)
        }
    }
    
    
    @IBAction func removeComponent(sender: AnyObject) {
        if tableView.selectedRow >= 0 {
            workflow!.components.removeAtIndex(tableView.selectedRow)
            tableView.reloadData()
        }
    }
    
    
    @IBAction func displaySelectComponentPanel(sender: AnyObject) {
        componentDropdown.removeAllItems()
        componentDropdown.addItemsWithTitles(registeredComponents)
        workflowWindow.beginSheet(selectComponentPanel, completionHandler: nil)
    }

    
    @IBAction func closeSelectComponentPanel(sender: NSButton!) {
        let ComponentObj: BaseComponent
        if sender.title == "OK" {
            let componentID = workflow!.components.count
            ComponentObj = newComponentObj(componentDropdown.selectedItem?.title, id: componentID, workflowId: workflow!.workflowID, workflowName: workflow!.name) as! BaseComponent
            workflow?.components.append(ComponentObj)
            workflowWindow.endSheet(selectComponentPanel)
            ComponentObj.displayComponentPanel(workflowWindow!)
            
        } else if sender.title == "Cancel" {
            NSLog("User cancelled selecting new component")
            workflowWindow.endSheet(selectComponentPanel)
        } else{
            workflowWindow.endSheet(selectComponentPanel)
        }
    }
    
    @IBAction func reloadTableView(sender: AnyObject) {
        tableView.reloadData()
    }
    
    @IBAction func okClicked(sender: AnyObject) {
        workflowWindow.orderOut(nil)
    }
    
}


extension WorkflowViewController: NSTableViewDataSource {
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        if workflow!.components != nil {
            return workflow!.components.count ?? 0
        } else {
            return 0
        }
    }
}

extension WorkflowViewController: NSTableViewDelegate {
    
    func tableView(tableView: NSTableView, viewForTableColumn tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        let component = workflow!.components[row]
        if tableColumn == tableView.tableColumns[0] {
            text = component.type
            cellIdentifier = "TypeCellID"
        }
        
        if let cell = tableView.makeViewWithIdentifier(cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }
    
    @IBAction func tableViewDoubleClick(sender: AnyObject) {
        guard tableView.selectedRow >= 0 , let component = workflow!.components?[tableView.selectedRow] else {
            return
        }
        component.displayComponentPanel(workflowWindow)
        
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
    
    func tableView(tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableViewDropOperation) -> Bool
    {
        let data:NSData = info.draggingPasteboard().dataForType(NSStringPboardType)!
        let rowIndexes:NSIndexSet = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! NSIndexSet
        
        if ((info.draggingSource() as! NSTableView == tableView) && (tableView == tableView)) {
            let value = workflow!.components[rowIndexes.firstIndex]
            workflow!.components!.removeAtIndex(rowIndexes.firstIndex)
            
            if (row > workflow!.components!.count){
                workflow!.components!.insert(value, atIndex: row-1)
            } else {
                workflow!.components!.insert(value, atIndex: row)
            }
            tableView.reloadData()
            return true
        } else {
            return false
        }
    }
}

