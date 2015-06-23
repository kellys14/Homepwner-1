//
//  DetailViewController.swift
//  Homepwner
//
//  Created by Bryan Robinson on 6/9/15.
//  Copyright (c) 2015 Bryan Robinson. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var serialField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    
    let item: Item
    let imageStore: ImageStore
    
    var isNew: Bool = false {
        didSet {
            if isNew {
                // If this is a new item, provide Cancel and Done buttons
                let cancelItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancel:")
                navigationItem.leftBarButtonItem = cancelItem
                
                let doneItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "save:")
                navigationItem.rightBarButtonItem = doneItem
            }
            else {
                // Not new
                navigationItem.leftBarButtonItem = navigationItem.backBarButtonItem
                navigationItem.rightBarButtonItem = nil
            }
        }
    }
    
    var cancelClosure: (() -> Void)?
    var saveClosure: (() -> Void)?
    
    init(item: Item, imageStore: ImageStore) {
        self.item = item
        self.imageStore = imageStore
        super.init(nibName: "DetailViewController", bundle: nil)
        
        navigationItem.title = item.name
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.text = item.name
        if let sn = item.serialNumber {
            serialField.text = sn
        }
        valueField.text = "\(item.valueInDollars)"
        
        let date = item.dateCreated
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        
        dateLabel.text = dateFormatter.stringFromDate(date)
        
        // Get the item key
        let key = item.itemKey
        
        // Display the image if one found
        if let imageToDisplay = imageStore.imageForKey(key) {
            imageView.image = imageToDisplay
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Clear first responder
        view.endEditing(true)
        
        // Save changes to item
        item.name = nameField.text
        item.serialNumber = serialField.text
        item.valueInDollars = valueField.text.toInt() ?? 0
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let iv = UIImageView()
//        
//        // The contentMode of the image view in the XIB was Aspect Fit:
//        iv.contentMode = .ScaleAspectFit
//        
//        // Do not produce a translated constraint for this view
//        iv.setTranslatesAutoresizingMaskIntoConstraints(false)
//        
//        // The image view was a subview of the view
//        view.addSubview(iv)
//        
//        // The image view was pointed to by the imageView property
//        imageView = iv
//        
//        imageView.setContentHuggingPriority(200, forAxis: .Vertical)
//        
//        let nameMap = ["imageView":imageView, "dateLabel":dateLabel, "toolbar":toolbar]
//        
//        // imageView is 0 pts from superview at left and right edges
//        let horizontalConstraints =
//        NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[imageView]-0-|",
//            options: nil,
//            metrics: nil,
//            views: nameMap)
//        
//        // imageView is 8 pts from dateLabel at its top edge...
//        // ... and 8 pts from toolbar at its bottom edge
//        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[dateLabel]-8-[imageView]-8-[toolbar]",
//            options: nil,
//            metrics: nil,
//            views: nameMap)
//        
//        NSLayoutConstraint.activateConstraints(horizontalConstraints)
//        NSLayoutConstraint.activateConstraints(verticalConstraints)
//    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func onChangeDate(sender: AnyObject) {
        let dpvc = DatePickerViewController(item: self.item)
        
        showViewController(dpvc, sender: self)
    }
    
    @IBAction func takePicture(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        // If the device has a camera, take a picture, otherwise just pick from photo library
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            imagePicker.sourceType = .Camera

            let midHeight = view.bounds.height / 2
            let midWidth = view.bounds.width / 2
            let small = CGRect(x: midWidth, y: midHeight, width: 20, height: 20)
            
//            imagePicker.cameraOverlayView = CrosshairView(frame: view.bounds)
            imagePicker.cameraOverlayView = CrosshairView(frame: small)
        }
        else {
            imagePicker.sourceType = .PhotoLibrary
        }
        
        imagePicker.delegate = self
        imagePicker.modalPresentationStyle = UIModalPresentationStyle.Popover
        imagePicker.popoverPresentationController?.barButtonItem = sender as! UIBarButtonItem
        imagePicker.popoverPresentationController?.backgroundColor = UIColor.redColor()
        
        // Bronze Challenge - Chapter 11
        imagePicker.allowsEditing = true
        
        // Place image picker on the screen
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        
        // Get picked image from info dictionary
        
        // Bronze Challenge - Chapter 112
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        let image = info[UIImagePickerControllerEditedImage] as! UIImage
        
        // Store the image in the ImageStore for the item's key
        imageStore.setImage(image, forKey:item.itemKey)
        
        // Put that image onto the screen in our image view
        imageView.image = image
        
        // Take image picker off the screen 
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Silver Challenge - Chapter 11
    @IBAction func removeImageFromItem(sender: AnyObject) {
        imageView.image = nil
        imageStore.deleteImageForKey(item.itemKey)
    }
    
    @IBAction func backgroundTapped(sender: AnyObject) {
        view.endEditing(true)
    }
    
    override func viewDidLayoutSubviews() {
        for subview in view.subviews as! [UIView] {
            if subview.hasAmbiguousLayout() {
                println("AMBIGUOUS: \(subview)")
            }
        }
    }
    
    func save(sender: AnyObject) {
        saveClosure?()
    }
    
    func cancel(sender:AnyObject) {
        cancelClosure?()
    }
}
