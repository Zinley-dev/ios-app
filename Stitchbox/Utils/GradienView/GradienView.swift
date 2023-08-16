//
//  GradienView.swift
//  Dual
//
//  Created by Khoi Nguyen on 6/20/22.
//

import Foundation
import AsyncDisplayKit

class GradienView: ASDisplayNode {
    
    // Cached gradient. Color space in this context is managed by ARC.
    private static let myGradient: CGGradient? = {
        let zero = CGFloat(0.0)
        let one = CGFloat(0.75)
        let locations = [zero, one]
        let components = [zero, zero, zero, one, zero, zero, zero, zero]
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
        
        return gradient
    }()
    
    override class func draw(_ bounds: CGRect, withParameters parameters: Any?, isCancelled isCancelledBlock: () -> Bool, isRasterizing: Bool) {
        
        guard let myContext = UIGraphicsGetCurrentContext(), let myGradient = GradienView.myGradient else { return }
        
        myContext.saveGState()
        myContext.clip(to: bounds)
        
        let myStartPoint = CGPoint(x: bounds.midX, y: bounds.maxY)
        let myEndPoint = CGPoint(x: bounds.midX, y: bounds.midY)
      
        myContext.drawLinearGradient(myGradient, start: myStartPoint, end: myEndPoint, options: [CGGradientDrawingOptions.drawsAfterEndLocation])
        
        myContext.restoreGState()
    }
    
}


