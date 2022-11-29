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
            frame.size.height = 42.0;
        }
        
        layer.cornerRadius = self.frame.height / 2
        layer.borderWidth = 1.0
        clipsToBounds = true
        // Setup the Button Depending on What State it is in]
        if !self.isEnabled {
            setDisabled()
        } else if self.isHovered {
            setHover()
        } else if self.isSelected {
            setSelected()
        } else {
            setDefault()
        }
    }
    
    // Set the default properties
    func setDefault() {
        switch isPrimary {
        case true:
            backgroundColor = UIColor.primary
            tintColor = UIColor.other
            layer.borderColor = UIColor.primary.cgColor
        case false:
            backgroundColor = UIColor.other
            tintColor = UIColor.secondary
            layer.borderColor = UIColor.secondary.cgColor
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
    func setHover() {
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
    
}

#if canImport(SwiftUI) && DEBUG

struct ButtonViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        return UIStoryboard(name: "Empty", bundle: nil).instantiateInitialViewController()!.view
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
