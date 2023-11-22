//
//  CustomSlider.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 11/21/23.
//

import UIKit

/// A custom slider subclass of `UISlider` that allows for various customizations such as track height,
/// thumb radius, and hit box size.
class CustomSlider: UISlider {
    
    // MARK: - Inspectable Properties
    
    @IBInspectable var trackHeight: CGFloat = 1
    @IBInspectable var highlightedTrackHeight: CGFloat = 7.0
    @IBInspectable var thumbRadius: CGFloat = 2
    @IBInspectable var highlightedThumbRadius: CGFloat = 10
    @IBInspectable var hitBoxSize: CGFloat = 40 // Size of the hit box area
    
    // MARK: - Private Properties
    
    private var thumbImageCache: [CGFloat: UIImage] = [:]
    private lazy var thumbView: UIView = {
        let thumb = UIView()
        thumb.backgroundColor = .clear
        return thumb
    }()
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSlider()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSlider()
    }
    
    // MARK: - Setup Methods
    
    /// Sets up the slider with initial configurations.
    private func setupSlider() {
        setThumbImage(thumbImage(radius: thumbRadius), for: .normal)
        maximumTrackTintColor = .darkGray
        minimumTrackTintColor = .secondary
    }
    
    /// Generates a thumb image for a given radius.
    /// - Parameter radius: The radius of the thumb image.
    /// - Returns: A `UIImage` representing the thumb.
    private func thumbImage(radius: CGFloat) -> UIImage {
        if let cachedImage = thumbImageCache[radius] {
            return cachedImage
        }
        
        thumbView.frame = CGRect(x: 0, y: 0, width: radius * 2, height: radius * 2)
        thumbView.layer.cornerRadius = radius
        thumbView.layer.masksToBounds = true
        
        let renderer = UIGraphicsImageRenderer(bounds: thumbView.bounds)
        let generatedImage = renderer.image { context in
            thumbView.layer.render(in: context.cgContext)
        }
        
        thumbImageCache[radius] = generatedImage
        return generatedImage
    }

    // MARK: - Overridden Methods
    
    /// Overrides the hit test to expand the touch area.
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = bounds.insetBy(dx: -(hitBoxSize / 2 - thumbRadius), dy: -(hitBoxSize / 2 - thumbRadius))
        return expandedBounds.contains(point)
    }
    
    /// Customizes the track rectangle.
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        var newRect = super.trackRect(forBounds: bounds)
        newRect.size.height = trackHeight
        return newRect
    }
    
    // MARK: - Layout Update Methods
    
    /// Adjusts the layout for a highlighted state.
    func startLayout() {
        setThumbImage(thumbImage(radius: highlightedThumbRadius), for: .normal)
        trackHeight = highlightedTrackHeight
        hitBoxSize = highlightedThumbRadius * 2 + 40
        setNeedsDisplay()
    }

    /// Adjusts the layout for a normal state.
    func endLayout() {
        setThumbImage(thumbImage(radius: thumbRadius), for: .normal)
        trackHeight = 1
        hitBoxSize = thumbRadius * 2 + 40
        setNeedsDisplay()
    }
}

