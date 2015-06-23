//
//  ImageStore.swift
//  Homepwner
//
//  Created by Bryan Robinson on 6/10/15.
//  Copyright (c) 2015 Bryan Robinson. All rights reserved.
//

import UIKit

class ImageStore: NSObject {
    
    var imageDictionary = [String:UIImage]()
    
    override init() {
        super.init()
        
        let nc = NSNotificationCenter.defaultCenter()
        nc.addObserver(self, selector: "clearCache:", name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)
    }
   
    func setImage(image: UIImage, forKey key: String) {
        imageDictionary[key] = image
        
        // Create full URL for image
        let imageURL = imageURLForKey(key)
        
        // Turn image into JPEG data
//        let data = UIImageJPEGRepresentation(image, 0.5)
        
        // Bronze Challenge = Chapter 12
        let data = UIImagePNGRepresentation(image)
        
        // Write it to full URL
        data.writeToURL(imageURL, atomically: true)
    }
    
    func imageForKey(key: String) -> UIImage? {
       
        if let existingImage = imageDictionary[key] {
            return existingImage
        }
        else {
            let imageURL = imageURLForKey(key)
            
            if let imageFromDisk = UIImage(contentsOfFile: imageURL.path!) {
                imageDictionary[key] = imageFromDisk
                return imageFromDisk
            }
            else {
                return nil
            }
        }
    }
    
    func deleteImageForKey(key: String) {
        imageDictionary.removeValueForKey(key)
        
        let imageURL = imageURLForKey(key)
        NSFileManager.defaultManager().removeItemAtURL(imageURL, error: nil)
    }
    
    func imageURLForKey(key: String) -> NSURL {
        let documentsDirectories = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        let documentDirectory = documentsDirectories.first as! NSURL
        
        return documentDirectory.URLByAppendingPathComponent(key)
    }
    
    func clearCache(note: NSNotification) {
        println("Flushing \(imageDictionary.count) images out of the cache")
        imageDictionary.removeAll(keepCapacity: false)
    }
}
