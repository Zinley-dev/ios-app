//
//  SButton.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 30/11/2022.
//

import UIKit
import SwiftUI

@IBDesignable class SButton: UIButton {

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
        print("Setdefault")
        switch isPrimary {
        case true:
            backgroundColor = UIColor.primary
            tintColor = UIColor.other
            layer.borderColor = UIColor.primary.cgColor
        case false:
            backgroundColor = UIColor.other
            tintColor = UIColor.secondary
            layer.borderColor = UIColor.primary.cgColor
        }
    }

    // Set the selected properties
    func setSelected() {
        print("SetSelected")
        switch isPrimary {
        case true:
            backgroundColor = UIColor.primary
            tintColor = UIColor.other
            layer.borderColor = UIColor.primary.cgColor
        case false:
            backgroundColor = UIColor.secondary
            tintColor = UIColor.other
            layer.borderColor = UIColor.primary.cgColor
        }
    }


    // Set the deselcted properties
    func setHover() {
        print("SetHover")
        switch isPrimary {
        case true:
            backgroundColor = UIColor.tertiary
            tintColor = UIColor.other
            layer.borderColor = UIColor.tertiary.cgColor
        case false:
            backgroundColor = UIColor.tertiary
            tintColor = UIColor.secondary
            layer.borderColor = UIColor.tertiary.cgColor
        }
    }

    // Set the deselcted properties
    func setDisabled() {
        switch isPrimary {
        case true:
            backgroundColor = UIColor.disabled
            tintColor = UIColor.other
            self.layer.borderColor = UIColor.disabled.cgColor

        case false:
            self.backgroundColor = UIColor.other
            tintColor = UIColor.disabled
            self.layer.borderColor = UIColor.disabled.cgColor
        }
    }
    // MARK: - UI Setup
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()

    }
    override var isSelected: Bool {
        didSet {
            setupView()
        }
    }
    override var isEnabled: Bool {
        didSet {
            setupView()
        }
    }

}

#if canImport(SwiftUI) && DEBUG

struct ButtonViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return UIStoryboard(name: "Components", bundle: nil).instantiateViewController(withIdentifier: "Button").view
    }

    func updateUIView(_ view: UIView, context: Context) {

    }
}

@available(iOS 13, *)
struct ButtonView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            ButtonViewRepresentable()
        }
    }
}
#endif
