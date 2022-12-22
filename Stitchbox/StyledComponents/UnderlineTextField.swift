//
//  UnderlineTextField.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 01/12/2022.
//

import Foundation
import UIKit
import SwiftUI

@IBDesignable class UnderlineTextField: UITextField {

    var leftPadding = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 0)
    let border = CALayer()
    @IBInspectable var borderColor: UIColor {
        get {
            return self.borderColor
        }
        set {
            self.border.backgroundColor = newValue.cgColor
        }
    }
    
    @IBInspectable var paddingLeft: CGFloat {
        get {
            return self.paddingLeft
        }
        set {
            self.leftPadding.left = newValue
        }
    }
    @IBInspectable override var placeHolderColor: UIColor? {
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
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    func setupView() {
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
        backgroundColor = UIColor.clear
        tintColor = UIColor.secondary
        clipsToBounds = false
        layer.borderWidth = 0.0
        layer.cornerRadius = 0
        borderStyle = .none
        border.frame = CGRect(x:0, y:self.frame.size.height + 5, width:self.frame.size.width, height:1)
        self.layer.addSublayer(border)
    }

    // Set the selected properties
    func setSelected() {
            backgroundColor = UIColor.secondary
            tintColor = UIColor.other
            layer.borderColor = UIColor.secondary.cgColor
        
    }


    // Set the deselcted properties
    func setDisabled() {
        
            self.backgroundColor = UIColor.other
            tintColor = UIColor.disabled
            self.layer.borderColor = UIColor.disabled.cgColor
        
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

struct UnderlineTextFieldViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Components", bundle: nil).instantiateViewController(withIdentifier: "UnderlineTextfield")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController
    
}

@available(iOS 13, *)
struct UnderlineTextfieldView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            UnderlineTextFieldViewRepresentable()
        }
    }
}
#endif
