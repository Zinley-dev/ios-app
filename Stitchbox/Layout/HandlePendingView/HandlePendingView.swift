//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

// MARK: - HandlePendingView Class
// This class represents a custom view designed for handling pending actions, such as approvals or declines.

class HandlePendingView: UIView {
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet var declineBtn: UIView!
    @IBOutlet var approveBtn: UIView!
   
    // The name of the XIB file from which the view is loaded.
    let kCONTENT_XIB_NAME = "HandlePendingView"
    
    // MARK: - Initializers
    // Initializer for creating the view programmatically.
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
        
        // Additional UI customization can be added here if necessary.
    }

    // Additional methods and configurations for HandlePendingView can be added here.
}

