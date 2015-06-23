//
//  ItemStore.swift
//  Homepwner
//
//  Created by Bryan Robinson on 6/9/15.
//  Copyright (c) 2015 Bryan Robinson. All rights reserved.
//

import UIKit

class ItemStore: NSObject {
 
    var allItems: [Item] = []
    let itemArchiveURL: NSURL = {
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectories.first as! NSURL
        return documentDirectory.URLByAppendingPathComponent("items.archive")
    }()
    
    override init() {
        super.init()
        
        if let archivedItems = NSKeyedUnarchiver.unarchiveObjectWithFile(itemArchiveURL.path!) as? [Item] {
            allItems += archivedItems
        } else {
            // Silver Challenge
            let lastRowItem = Item(name: "No More Items!", serialNumber: "", valueInDollars: 0)
            allItems.append(lastRowItem)
        }
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "appDidEnterBackground:", name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }
    
    func createItem() -> Item {
        let newItem = Item(random: false)
        allItems.insert(newItem, atIndex: 0)
        return newItem
    }
    
    func removeItem(item: Item) {
        if let index = find(allItems, item) {
            allItems.removeAtIndex(index)
        }
    }
    
    func moveItemAtIndex(fromIndex: Int, toIndex: Int) {
        if fromIndex == toIndex {
            return;
        }
        
        // Get reference to object
        let movedItem = allItems[fromIndex]
        
        // Remove item
        allItems.removeAtIndex(fromIndex)
        
        // Insert item back
        allItems.insert(movedItem, atIndex: toIndex)
    }
    
    func saveChanges() -> Bool {
        println("Saving items to: \(itemArchiveURL.path!)")
        return NSKeyedArchiver.archiveRootObject(allItems, toFile: itemArchiveURL.path!)
    }
    
    func appDidEnterBackground(note: NSNotification) {
        let success = saveChanges()
        if success {
            println("Saved all of the Items")
        }
        else {
            println("Could not save the Items")
        }
    }
}
