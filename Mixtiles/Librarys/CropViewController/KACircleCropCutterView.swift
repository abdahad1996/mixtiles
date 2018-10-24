//
//  KACircleCropCutterView.swift
//  Circle Crop View Controller
//
//  Created by Keke Arif on 21/02/2016.
//  Copyright © 2016 Keke Arif. All rights reserved.
//

import UIKit

class KACircleCropCutterView: UIView {
    
    override var frame: CGRect {
        
        didSet {
            setNeedsDisplay()
        }
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isOpaque = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.isOpaque = false
    }

    override func draw(_ rect: CGRect) {
        print(rect)
        let context = UIGraphicsGetCurrentContext()
        
        UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).setFill()
        UIRectFill(rect)
        
        var circle = UIBezierPath()
        var square = UIBezierPath()
        
        switch UIDevice().type {
        case .iPhoneSE,.iPhone5,.iPhone5S, .iPhone5C:
            circle = UIBezierPath(rect: CGRect(x: rect.size.width/2 - 280/2, y: rect.size.height/2 - 280/2, width: 280, height: 280))
            square = circle
        case .iPhone6, .iPhone7, .iPhone8, .iPhone6S, .iPhoneX, .iPhoneXS:
            circle = UIBezierPath(rect: CGRect(x: rect.size.width/2 - 320/2, y: rect.size.height/2 - 320/2, width: 320, height: 320))
            square = circle
        default:
            circle = UIBezierPath(rect: CGRect(x: rect.size.width/2 - 320/2, y: rect.size.height/2 - 320/2, width: 320, height: 320))
            square = circle
        }

        //This is the same rect as the UIScrollView size 240 * 240, remains centered
        
        context?.setBlendMode(.clear)
        UIColor.clear.setFill()
        circle.fill()
        
        //This is the same rect as the UIScrollView size 240 * 240, remains centered
//        square = UIBezierPath(rect: CGRect(x: rect.size.width/2 - 280/2, y: rect.size.height/2 - 280/2, width: 280, height: 280))
        UIColor.lightGray.setStroke()
        square.lineWidth = 1.0
        context?.setBlendMode(.normal)
        square.stroke()
        
    }
    
    //Allow touches through the circle crop cutter view
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in subviews as [UIView] {
            if !subview.isHidden && subview.alpha > 0 && subview.isUserInteractionEnabled && subview.point(inside: convert(point, to: subview), with: event) {
                return true
            }
        }
        return false
    }

}
