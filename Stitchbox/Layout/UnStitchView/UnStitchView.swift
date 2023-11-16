//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

// MARK: - UnStitchView Class
// This class represents a custom view, typically for an unstitch action, loaded from a XIB file.

class UnStitchView: UIView {
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet var unstitchBtn: UIView!
    
    // The name of the XIB file from which the view is loaded.
    let kCONTENT_XIB_NAME = "UnStitchView"
    
    // MARK: - Initializers
    // Initializer for creating the view from code.
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    // Required initializer for creating the view from a storyboard or XIB.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Common Initialization
    // Common setup code for the view, called from both initializers.
    func commonInit() {
        // Load the interface from the XIB file and attach it to this view.
        Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil)
        contentView.fixInView(self) // Helper method to fit the content view in this view's bounds.
        
        // Additional UI customization can be placed here if necessary.
    }

    // Any additional methods and configurations for UnStitchView can be added here.
}
