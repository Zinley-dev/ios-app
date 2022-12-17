//
//  CardStackView.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/10/22.
//

import UIKit
import SwiftUI
@IBDesignable class CardButton: UIButton {
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    // MARK: - UI Setup
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()

    }
    func setupView() {
        self.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .rightToLeft ? .forceLeftToRight : .forceRightToLeft

        self.frame.size.height = 30
        self.contentHorizontalAlignment = UIApplication.shared.userInterfaceLayoutDirection == .rightToLeft ? .right : .left
        
        self.semanticContentAttribute = UIApplication.shared
            .userInterfaceLayoutDirection == .leftToRight ? .forceLeftToRight : .forceRightToLeft
        
        let origImage = self.currentImage
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        self.setImage(tintedImage, for: .normal)
        self.tintColor = .text

    }
}
@IBDesignable class CardStackView: UIStackView {

    // IB: use the adapter
    @IBInspectable var border: Bool = true {
        didSet {
            if border == true {
                let gradient = CAGradientLayer()
                gradient.frame =  CGRect(origin: CGPoint.zero, size: self.frame.size)
                gradient.cornerRadius = 20
                gradient.colors = [UIColor.primary.cgColor, UIColor.secondary.cgColor]
                
                let shape = CAShapeLayer()
                shape.lineWidth = 5
                shape.path = UIBezierPath(roundedRect: self.bounds, cornerRadius: 20).cgPath
                shape.strokeColor = UIColor.black.cgColor
                shape.fillColor = UIColor.clear.cgColor
                gradient.mask = shape
                gradient.shadowColor = UIColor.black.cgColor
                gradient.shadowOpacity = 1
                gradient.shadowOffset = CGSize(width: 0, height: 4)
                gradient.shadowRadius = 4
                self.layer.addSublayer(gradient)

            } else {
                
                layer.shadowColor = UIColor.black.cgColor
                layer.shadowOpacity = 0.15
                self.cornerRadius = 20
            }
        }
    }
    // IB: use the adapter
    @IBInspectable var haveSwitch: Int = 0 {
        didSet {
            setupView()
        }
    }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
        self.backgroundColor = .background
        self.tintColor = .text
    }

    // MARK: - UI Setup
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

}

#if canImport(SwiftUI) && DEBUG

struct CardStackViewViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return UIStoryboard(name: "Components", bundle: nil).instantiateViewController(withIdentifier: "CARD").view
    }

    func updateUIView(_ view: UIView, context: Context) {

    }
}

@available(iOS 13, *)
struct CardStackViewViewPreview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            CardStackViewViewRepresentable()
        }
    }
}
#endif
extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}
