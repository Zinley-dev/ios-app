//
//  LoginButton.swift
//  Stitchbox
//
//  Created by Nguyen Vo Thuan on 12/27/22.
//
import UIKit
import SwiftUI

@IBDesignable class LoginButton: UIButton {
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleRect = super.titleRect(forContentRect: contentRect)
        let imageSize = currentImage?.size ?? .zero
        let availableWidth = contentRect.width - imageEdgeInsets.right - imageSize.width - titleRect.width
        return titleRect.offsetBy(dx: round(availableWidth / 2), dy: 0)
    }
    // IB: use the adapter
    @IBInspectable var isPrimary: Bool = true {
        didSet {
            setupView()
        }
    }
    // IB: use the adapter
    @IBInspectable var size: Int = 0 {
        didSet {
            setupView()
        }
    }
    
    @IBInspectable var leftImage: UIImage = UIImage() {
        didSet {
            setupView()
        }
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        
        if size == 0 {
            frame.size.height = 32.0;
        } else if size == 1 {
            frame.size.height = 36.0;
        } else if size == 2 {
            frame.size.height = 44.0;
        }
        
        
        
        layer.cornerRadius = self.frame.height / 3
        layer.borderWidth = 1.0
        clipsToBounds = true
        
        // shadow
        layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        layer.shadowOpacity = 0.75
        layer.shadowRadius = 2
        layer.masksToBounds = false
        
        
        let leftImageView = UIImageView(frame: CGRect(x: 10, y: (titleLabel?.bounds.midY)! + 5, width: 30, height: 30))
        leftImageView.image?.withRenderingMode(.alwaysOriginal)
        leftImageView.image = leftImage
        leftImageView.contentMode = .scaleAspectFit
        leftImageView.tintColor = .text
        leftImageView.layer.masksToBounds = true
        
        self.addSubview(leftImageView)
        // Setup the Button Depending on What State it is in]
        if #available(iOS 15.0, *) {
            if !self.isEnabled {
                setDisabled()
            } else if self.isHovered {
                setHover()
            } else if self.isSelected {
                setSelected()
            } else {
                setDefault()
            }
        } else {
            // Fallback on earlier versions
            
        }
    }
    
    // Set the default properties
    func setDefault() {
        
    }
    
    // Set the selected properties
    func setSelected() {
        
    }
    
    
    // Set the deselcted properties
    func setHover() {
    }
    
    // Set the deselcted properties
    func setDisabled() {
    }
    // MARK: - UI Setup
    override func prepareForInterfaceBuilder() {
        
    }
    override var isSelected: Bool {
        didSet {
            setupView()
        }
    }
    
}




#if canImport(SwiftUI) && DEBUG

struct LoginButtonRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Login").view
    }
    
    func updateUIView(_ view: UIView, context: Context) {
        
    }
}

@available(iOS 13, *)
struct LoginButtonPreview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            LoginButtonRepresentable()
        }
    }
}
#endif

