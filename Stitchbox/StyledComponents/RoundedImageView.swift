//
//  RoundedImageView.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/24/22.
//

import Foundation
import UIKit

@IBDesignable
class RoundedImageView: UIImageView {
    @IBInspectable var imageSize: CGSize = CGSize(width: 30, height: 30) {
        didSet{
            self.image = self.image?.resize(withSize: imageSize, contentMode: .contentAspectFill)
            self.layer.bounds.size = self.image!.size
            self.frame.size = self.image!.size
            layoutSubviews()
        }
    }
    
    @IBInspectable var borderRadius: Double = -1 {
        didSet {
            if (borderRadius == -1) {
                self.layer.cornerRadius = (self.frame.size.width / 2)
            } else {
                self.layer.cornerRadius = borderRadius
                self.clipsToBounds = true
                
            }
        }
    }
    override init(image: UIImage?) {
        super.init(image: image)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
}
