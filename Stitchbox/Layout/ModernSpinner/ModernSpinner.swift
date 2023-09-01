//
//  ModernSpinner.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 9/1/23.
//

import UIKit

class ModernSpinner: UIView {
    var spinnerLayer: CAShapeLayer!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSpinner()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupSpinner()
    }
    
    func setupSpinner() {
        spinnerLayer = CAShapeLayer()
        spinnerLayer.bounds = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
        spinnerLayer.position = CGPoint(x: bounds.midX, y: bounds.midY)
        spinnerLayer.strokeColor = UIColor.blue.cgColor
        spinnerLayer.lineWidth = 4.0
        spinnerLayer.fillColor = nil
        spinnerLayer.path = UIBezierPath(arcCenter: spinnerLayer.position,
                                         radius: bounds.size.width / 2,
                                         startAngle: 0,
                                         endAngle: .pi * 1.5,
                                         clockwise: true).cgPath
        
        layer.addSublayer(spinnerLayer)
    }
    
    func startAnimating() {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat.pi * 2.0
        rotateAnimation.duration = 1.0
        rotateAnimation.repeatCount = .infinity
        spinnerLayer.add(rotateAnimation, forKey: "rotate")
    }
    
    func stopAnimating() {
        spinnerLayer.removeAnimation(forKey: "rotate")
    }
}

