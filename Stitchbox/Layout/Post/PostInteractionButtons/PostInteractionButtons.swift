//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit

// MARK: - PostInteractionButtons Class
// This class represents a custom view for displaying interaction buttons on a post,
// including share, comment, like, and save buttons along with their respective counts.

class PostInteractionButtons: UIView {
    
    // MARK: - Outlets
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var commentBtn: UIButton!
    @IBOutlet weak var commentCountLbl: UILabel!
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var likeCountLbl: UILabel!
    @IBOutlet weak var shareCountLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var saveCountLbl: UILabel!

    // Constant for the XIB file name.
    let kCONTENT_XIB_NAME = "PostInteractionButtons"
    
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

        // Further customization and setup for buttons and labels can be done here.
    }

    // Additional methods and configurations for PostInteractionButtons can be added here.
}
