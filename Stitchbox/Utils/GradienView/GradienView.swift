//
//  GradienView.swift
//  Dual
//
//  Created by Khoi Nguyen on 6/20/22.
//

import Foundation
import AsyncDisplayKit


class GradienView: ASDisplayNode {
    
    override class func draw(_ bounds: CGRect, withParameters parameters: Any?, isCancelled isCancelledBlock: () -> Bool, isRasterizing: Bool) {
        
        let myContext = UIGraphicsGetCurrentContext()
        
        myContext?.saveGState()
        myContext?.clip(to: bounds)
        
        let componentCount = 2
        let zero = CGFloat(0.0)
        let one = CGFloat(0.75)
        let locations = [zero, one]
        let components = [zero, zero, zero, one, zero, zero, zero, zero]
        
        let myColorSpace = CGColorSpaceCreateDeviceRGB()
        let myGradient = CGGradient.init(colorSpace: myColorSpace, colorComponents: components, locations: locations, count: componentCount)!
        
        let myStartPoint = CGPoint(x: bounds.midX, y: bounds.maxY)
        let myEndPoint = CGPoint(x: bounds.midX, y: bounds.midY)
      
        myContext?.drawLinearGradient(myGradient, start: myStartPoint, end: myEndPoint, options: [CGGradientDrawingOptions.drawsAfterEndLocation])
        
        myContext?.restoreGState()
    
        
    }
    
}
