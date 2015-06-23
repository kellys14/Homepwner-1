//
//  DatePickerViewController.swift
//  Homepwner
//
//  Created by Bryan Robinson on 6/9/15.
//  Copyright (c) 2015 Bryan Robinson. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {
    
    var item: Item
    
    init(item: Item) {
        self.item = item
        super.init(nibName: "DatePickerViewController", bundle: nil)
        
        navigationItem.title = item.name
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @IBOutlet weak var datePicker: UIDatePicker!

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clear first responder
        view.endEditing(true)
        
        // Save changes to item
        item.dateCreated = datePicker.date
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.datePicker.date = item.dateCreated
    }

}
