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
    private var editButton: UIButton?
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
    @IBInspectable override var placeHolderColor: UIColor? {
            get {
                return self.placeHolderColor
            }
            set {
                self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!])
            }
        }
    
    @IBInspectable var haveEditButton: Bool = false {
        didSet {
            if haveEditButton {
                editButton = UIButton(type: .custom)
                editButton?.setImage(UIImage(named: "edit"), for: .normal)
                editButton?.imageEdgeInsets = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
                editButton?.frame = CGRect(x: CGFloat(self.frame.size.width - 25), y: CGFloat(5), width: CGFloat(25), height: CGFloat(25))
                editButton?.addTarget(self, action: #selector(self.editAllow), for: .touchDown)

                self.rightView = editButton
                self.rightViewMode = .always
                
            }
        }
    }
    @IBInspectable var setEditable: Bool = true {
        didSet {
            self.allowsEditingTextAttributes = self.setEditable
        }
    }
    @IBAction func editAllow(_ sender: Any) {
        self.becomeFirstResponder()
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

struct TextFieldViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Components", bundle: nil).instantiateViewController(withIdentifier: "Textfield")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController
    
}

@available(iOS 13, *)
struct TextfieldView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            TextFieldViewControllerRepresentable()
        }
    }
}
#endif
