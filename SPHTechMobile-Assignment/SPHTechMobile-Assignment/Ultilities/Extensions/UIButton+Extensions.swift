//
//  UIButton+Extensions.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/2/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import UIKit

private var pTouchAreaEdgeInsets: UIEdgeInsets = UIEdgeInsets.zero
public extension UIButton {
    // Ref: http://stackoverflow.com/questions/808503/uibutton-making-the-hit-area-larger-than-the-default-hit-area
    var touchAreaEdgeInsets: UIEdgeInsets {
        get {
            if let value = objc_getAssociatedObject(self, &pTouchAreaEdgeInsets) as? NSValue {
                var edgeInsets = UIEdgeInsets.zero
                value.getValue(&edgeInsets)
                return edgeInsets
            } else {
                return UIEdgeInsets.zero
            }
        }
        set(newValue) {
            var newValueCopy = newValue
            let objCType = NSValue(uiEdgeInsets: UIEdgeInsets.zero).objCType
            let value = NSValue(&newValueCopy, withObjCType: objCType)
            objc_setAssociatedObject(self, &pTouchAreaEdgeInsets, value, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if self.touchAreaEdgeInsets == UIEdgeInsets.zero || !self.isEnabled || self.isHidden {
            return super.point(inside: point, with: event)
        }
        
        let relativeFrame = self.bounds
        let hitFrame = relativeFrame.inset(by: self.touchAreaEdgeInsets)
        
        return hitFrame.contains(point)
    }
    
    func scaleFontToFitWidth(withInsets insets: UIEdgeInsets, minScaleFactor: CGFloat = 0.7) {
        self.titleLabel?.adjustsFontSizeToFitWidth = true
        self.titleLabel?.minimumScaleFactor = minScaleFactor
        self.contentEdgeInsets = insets
        self.contentVerticalAlignment = .center
    }
    
    func verticallyAlignCenter() {
        self.titleLabel?.baselineAdjustment = .alignCenters
    }
}
