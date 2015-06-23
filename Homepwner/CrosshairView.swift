//
//  CrosshairView.swift
//  Homepwner
//
//  Created by Bryan Robinson on 6/10/15.
//  Copyright (c) 2015 Bryan Robinson. All rights reserved.
//

import UIKit

class CrosshairView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.clearColor()
    }
    
    convenience required init(coder aDecoder: NSCoder) {
        self.init(frame: CGRectZero)
    }

    override func drawRect(rect: CGRect) {
        let path = UIBezierPath()
        
        // Vertical
        path.moveToPoint(CGPointMake(center.x, center.y - 20))
        path.addLineToPoint(CGPointMake(center.x, center.y + 20))
        
        // Horizontal
        path.moveToPoint(CGPointMake(center.x - 20, center.y))
        path.addLineToPoint(CGPointMake(center.x + 20, center.y))
        
        UIColor.blueColor().setStroke()
        path.stroke()
    }
}
