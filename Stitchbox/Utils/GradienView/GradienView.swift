//
//  GradienView.swift
//  Dual
//
//  Created by Khoi Nguyen on 6/20/22.
//

import Foundation
import AsyncDisplayKit

// MARK: - GradienView Class
// A custom ASDisplayNode subclass that renders a linear gradient.

class GradienView: ASDisplayNode {
    
    // Cached gradient. The color space is managed by ARC.
    private static let myGradient: CGGradient? = {
        // Gradient color components and location points.
        let zero = CGFloat(0.0)
        let one = CGFloat(0.75)
        let locations = [zero, one]
        let components = [zero, zero, zero, one, zero, zero, zero, zero]
        
        // Creating a color space and gradient object.
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        return CGGradient(colorSpace: colorSpace, colorComponents: components, locations: locations, count: 2)
    }()
    
    // Custom drawing method for the node.
    override class func draw(_ bounds: CGRect, withParameters parameters: Any?, isCancelled isCancelledBlock: () -> Bool, isRasterizing: Bool) {
        // Ensuring the drawing context and gradient are available.
        guard let myContext = UIGraphicsGetCurrentContext(), let myGradient = GradienView.myGradient else { return }
        
        // Save the current state before modifying the context.
        myContext.saveGState()
        myContext.clip(to: bounds) // Clipping the drawing area to the bounds.

        // Drawing the bottom gradient
        let bottomStartPoint = CGPoint(x: bounds.midX, y: bounds.maxY)
        let bottomEndPoint = CGPoint(x: bounds.midX, y: bounds.midY/3)
        myContext.drawLinearGradient(myGradient, start: bottomStartPoint, end: bottomEndPoint, options: [.drawsAfterEndLocation])

        // Drawing the top gradient
        // The top area is half the height of the bottom area
        let topStartPoint = CGPoint(x: bounds.midX, y: bounds.minY)
        let topEndPoint = CGPoint(x: bounds.midX, y: bounds.midY / 4)
        myContext.drawLinearGradient(myGradient, start: topStartPoint, end: topEndPoint, options: [.drawsAfterEndLocation])

        // Restoring the context to its previous state.
        myContext.restoreGState()
    }
}


