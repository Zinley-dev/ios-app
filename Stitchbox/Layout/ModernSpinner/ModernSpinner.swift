//
//  ModernSpinner.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 9/1/23.
//

import UIKit

// MARK: - ModernSpinner Class
// This class represents a custom view for a spinning loader animation.
class ModernSpinner: UIView {
    // The layer that will be animated to create the spinner effect.
    var spinnerLayer: CAShapeLayer!
    
    // MARK: - Initializers
    // Initializes the spinner when created programmatically.
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSpinner()
    }
    
    // Required initializer for creating the view from a storyboard.
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSpinner()
    }
    
    // MARK: - Setup
    // Configures the spinner layer and its properties.
    func setupSpinner() {
        spinnerLayer = CAShapeLayer()
        spinnerLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        spinnerLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        spinnerLayer.strokeColor = UIColor.blue.cgColor // Spinner color
        spinnerLayer.lineWidth = 4.0 // Spinner line width
        spinnerLayer.fillColor = nil // Spinner does not fill the circle
        spinnerLayer.path = UIBezierPath(arcCenter: spinnerLayer.position,
                                         radius: bounds.size.width / 2,
                                         startAngle: 0,
                                         endAngle: .pi * 1.5,
                                         clockwise: true).cgPath
        layer.addSublayer(spinnerLayer)
    }
    
    // MARK: - Animation Control
    // Starts the spinning animation.
    func startAnimating() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat.pi * 2.0 // Full circle rotation
        rotateAnimation.duration = 1.0 // Duration of one complete spin
        rotateAnimation.repeatCount = .infinity // Repeat indefinitely
        spinnerLayer.add(rotateAnimation, forKey: "rotate")
    }
    
    // Stops the spinning animation.
    func stopAnimating() {
        spinnerLayer.removeAnimation(forKey: "rotate")
    }
}

