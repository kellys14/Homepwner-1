//
//  ItemsViewController.swift
//  Homepwner
//
//  Created by Bryan Robinson on 6/9/15.
//  Copyright (c) 2015 Bryan Robinson. All rights reserved.
//

import UIKit

class ItemsViewController: UITableViewController {
   
    let itemStore: ItemStore
    let imageStore: ImageStore
    
    init(itemStore: ItemStore, imageStore: ImageStore) {
        self.itemStore = itemStore
        self.imageStore = imageStore
        super.init(nibName: nil, bundle: nil)
        
//        navigationItem.title = "Homepwner"
        navigationItem.title = NSLocalizedString("Homepwner", comment: "Name of application")
        
        // Create a new add button
        let addItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "addNewItem:")
        navigationItem.rightBarButtonItem = addItem
        
        navigationItem.leftBarButtonItem = editButtonItem()
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemStore.allItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // Get a new or recycled cell
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemCell", forIndexPath: indexPath) as! ItemCell
        
        let item = itemStore.allItems[indexPath.row]
        
        // Configure the cell with the Item
        cell.nameLabel.text = item.name
        cell.serialNumberLabel.text = item.serialNumber
        
        // Create a number formatter for currency
        let currencyFormatter = NSNumberFormatter()
        currencyFormatter.numberStyle = .CurrencyStyle
        
//        cell.valueLabel.text = "$\(item.valueInDollars)"
        cell.valueLabel.text = currencyFormatter.stringFromNumber(item.valueInDollars)
        
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 44

        // Load the NIB file
        let nib = UINib(nibName: "ItemCell", bundle: nil)
        
        // Register this NIB
        tableView.registerNib(nib, forCellReuseIdentifier: "ItemCell")
    }
    
    func addNewItem(sender: AnyObject) {
        let newItem = itemStore.createItem()
        
        let dvc = DetailViewController(item: newItem, imageStore: imageStore)
        dvc.isNew = true
        
        dvc.cancelClosure = {
            // Remove the new Item from the store
            self.itemStore.removeItem(newItem)
            
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        
        dvc.saveClosure = {
            // Figure out where it goes in the array
            if let index = find(self.itemStore.allItems, newItem) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
            
                // Insert this new row into the table
                self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
            }
            
            self.dismissViewControllerAnimated(true, completion: {
                self.tableView.reloadData()
            })
        }
        
        let nc = UINavigationController(rootViewController: dvc)
        nc.modalPresentationStyle = UIModalPresentationStyle.FormSheet
        presentViewController(nc, animated: true, completion: nil)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if editingStyle == .Delete {
            let item = itemStore.allItems[indexPath.row]
            
            let title = "Delete \(item.name)"
            let message = "Are you sure you want to delete this item?"
            
            let ac = UIAlertController(title: title, message: message, preferredStyle: .ActionSheet)
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
            ac.addAction(cancelAction)
            
            let deleteAction = UIAlertAction(title: "Delete", style: .Destructive, handler: { (action) -> Void in
                
                // Remove the item's image from the image store
                self.imageStore.deleteImageForKey(item.itemKey)
                
                self.itemStore.removeItem(item)
                
                self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                
            })
            ac.addAction(deleteAction)
            
            
            // Use popover presentation style
            ac.modalPresentationStyle = .Popover
            
            // Configure popover
            if let cell = tableView.cellForRowAtIndexPath(indexPath) {
                ac.popoverPresentationController?.sourceView = cell
                ac.popoverPresentationController?.sourceRect = cell.bounds
            }
            
            // Present the alert
            presentViewController(ac, animated: true, completion: nil)
        }
    }
    
    override func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        
        if destinationIndexPath.row != self.itemStore.allItems.count-1 {
            
            // Update the data
            itemStore.moveItemAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row)
            
        } else {
            // Gold challenge
            itemStore.moveItemAtIndex(sourceIndexPath.row, toIndex: destinationIndexPath.row - 1)
            tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String! {
        return "Remove"
    }
    
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.row == self.itemStore.allItems.count - 1 {
            return false
        }
        
        return true
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        // Get the selected item
        let item = itemStore.allItems[indexPath.row]
        
        // Create a DetailViewController
        let dvc = DetailViewController(item: item, imageStore: imageStore)
        
        showViewController(dvc, sender: self)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
}
