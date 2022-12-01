//
//  STextField.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/26/22.
//
import Foundation

import UIKit
import SwiftUI

@IBDesignable class STextField: UITextField {

    let leftPadding = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
    // IB: use the adapter
    @IBInspectable var isPrimary: Bool = true {
        didSet {
            print("setPrimary")
            setupView()
        }
    }
    // IB: use the adapter
    @IBInspectable var size: Int = 0 {
        didSet {
            print("size")
            setupView()
        }
    }
    @IBInspectable var placeHolderColor: UIColor? {
            get {
                return self.placeHolderColor
            }
            set {
                self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
            }
        }

    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("init 1")
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("init 2")
        setupView()
    }

    func setupView() {
        print("SETUP VIEW")
        if size == 0 {
            frame.size.height = 32.0;
        } else if size == 1 {
            frame.size.height = 36.0;
        } else if size == 2 {
            frame.size.height = 42.0;
        }

        // Setup the Textfield Depending on What State it is in]
        if !self.isEnabled {
            setDisabled()
        } else if self.isSelected {
            setSelected()
        } else {
            setDefault()
        }
    }

    // Set the default properties
    func setDefault() {
        print("Setdefault-1")
        switch isPrimary {
        case true:
            backgroundColor = UIColor.clear
            tintColor = UIColor.primary
//            textColor = UIColor.text
            layer.borderColor = UIColor.secondary.cgColor
            layer.cornerRadius = self.frame.height / 2
            layer.borderWidth = 2.0
            clipsToBounds = true
        case false:
            print("VAO FALSE")
            backgroundColor = UIColor.red
            tintColor = UIColor.secondary
            clipsToBounds = false
            layer.borderWidth = 0.0
            layer.cornerRadius = 0
            borderStyle = .none
//            let border = CALayer()
//            border.backgroundColor = UIColor.secondary.cgColor
//            border.frame = CGRect(x:0, y:self.frame.size.height - 5, width:self.frame.size.width, height:1)
//            self.layer.addSublayer(border)
        }
    }

    // Set the selected properties
    func setSelected() {
        switch isPrimary {
        case true:
            backgroundColor = UIColor.primary
            tintColor = UIColor.other
            layer.borderColor = UIColor.primary.cgColor
        case false:
            backgroundColor = UIColor.secondary
            tintColor = UIColor.other
            layer.borderColor = UIColor.secondary.cgColor
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
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: leftPadding)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: leftPadding)
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: leftPadding)
    }
}


#if canImport(SwiftUI) && DEBUG

struct TextfieldViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return UIStoryboard(name: "TextField", bundle: nil).instantiateInitialViewController()!.view
    }

    func updateUIView(_ view: UIView, context: Context) {

    }
}

@available(iOS 13, *)
struct TextfieldView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            TextfieldViewRepresentable()
        }
    }
}
#endif
