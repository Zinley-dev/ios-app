//
//  ButtonViews.swift
//  Dual
//
//  Created by Khoi Nguyen on 10/2/21.
//

import UIKit
import ActiveLabel

// MARK: - PostFooter Class
// This class represents a custom view for displaying the footer of a post,
// including elements like title, description, and an action button.

class PostFooter: UIView {
    
    // MARK: - Outlets
    @IBOutlet var contentView: UIView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var stitchBtn: UIButton!
    @IBOutlet var descriptionLbl: UILabel!
    
    var label: ActiveLabel!
    var customType: ActiveType!

    // Constant for the XIB file name.
    let kCONTENT_XIB_NAME = "PostFooter"
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Common Initialization
    func commonInit() {
        loadViewFromNib()
        setupActiveLabel()
        addLabelAsSubview()
        configureLayoutConstraints()
    }

    // Load the view from the nib file.
    private func loadViewFromNib() {
        guard Bundle.main.loadNibNamed(kCONTENT_XIB_NAME, owner: self, options: nil) != nil else {
            // Handle error: Nib loading failed.
            return
        }
        contentView.fixInView(self)
    }

    // Set up the ActiveLabel with initial configurations.
    private func setupActiveLabel() {
        label = ActiveLabel()
        label.backgroundColor = .clear

        // Define a custom regular expression for hashtags.
        // This pattern matches a hashtag followed by a non-word character (like a space or end of line) or another hashtag.
        let hashtagPattern = "#\\w+\\b(?=\\s|#|$)"
        customType = ActiveType.custom(pattern: hashtagPattern) // Custom type for hashtags

        // Enable the custom type for hashtag detection.
        label.enabledTypes = [customType]

        // Customization for hashtag appearance.
        label.customColor[customType] = UIColor(red: 208/255, green: 223/255, blue: 252/255, alpha: 1)
        label.customSelectedColor[customType] = UIColor.gray // Customize this color as needed

    }

    // Add the ActiveLabel as a subview and disable autoresizing mask constraints.
    private func addLabelAsSubview() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
    }

    // Define and activate layout constraints for the label.
    private func configureLayoutConstraints() {
        let constraints = [
            label.widthAnchor.constraint(equalTo: titleLbl.widthAnchor),
            label.heightAnchor.constraint(equalTo: titleLbl.heightAnchor),
            label.centerXAnchor.constraint(equalTo: titleLbl.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: titleLbl.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }


    // MARK: - Function to Set Footer Information
    /// Sets the footer information for the post.
    func setFooterInfo(title: String, description: String) {
        let attributedString: NSAttributedString
        let processedTitle: String

        // Check if the title is longer than 100 characters
        if title.count > 100 {
            // Get the first 80 characters of the title
            let index = title.index(title.startIndex, offsetBy: 100)
            processedTitle = String(title[..<index])
        } else {
            // If the title is 80 characters or less, use it as is
            processedTitle = title
        }

        // Create a paragraph style for trailing alignment and word wrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping

        // Create the attributes for the attributed string
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.roboto(.Bold, size: 13), // Using the Roboto Bold style
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]

        // Create the attributed string
        attributedString = NSAttributedString(string: processedTitle, attributes: attributes)

        // Assign the attributed text to the label
        titleLbl.text = processedTitle
        label.numberOfLines = titleLbl.numberOfLines
        label.attributedText = attributedString

        // Set the description label text
        descriptionLbl.text = ""
    }
    
    func setFooterInfoForDashboard(title: String, description: String) {
        titleLbl.font = FontManager.shared.roboto(.Bold, size: 10)
        let attributedString: NSAttributedString
        let processedTitle: String

        // Check if the title is longer than 100 characters
        if title.count > 100 {
            // Get the first 80 characters of the title
            let index = title.index(title.startIndex, offsetBy: 100)
            processedTitle = String(title[..<index])
        } else {
            // If the title is 80 characters or less, use it as is
            processedTitle = title
        }

        // Create a paragraph style for trailing alignment and word wrapping
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = .byWordWrapping

        // Create the attributes for the attributed string
        let attributes: [NSAttributedString.Key: Any] = [
            .font: FontManager.shared.roboto(.Bold, size: 10), // Using the Roboto Bold style
            .foregroundColor: UIColor.white,
            .paragraphStyle: paragraphStyle
        ]

        // Create the attributed string
        attributedString = NSAttributedString(string: processedTitle, attributes: attributes)

        // Assign the attributed text to the label
        titleLbl.text = processedTitle
        label.numberOfLines = titleLbl.numberOfLines
        label.attributedText = attributedString

        // Set the description label text
        descriptionLbl.text = ""
    }
    
    // MARK: - Cleanup Function
    func cleanup() {
        // Clear the text in labels to release any retained strings.
        titleLbl.text = nil
        descriptionLbl.text = nil

        // Reset the state of buttons if they are dynamically set.
        stitchBtn.setTitle(nil, for: .normal)

        // Clear any attributed text or custom settings in the ActiveLabel.
        label.text = nil
        label.attributedText = nil

        // Reset any custom properties or states you have set on the ActiveLabel.
        // For example, if you're modifying the appearance or behavior based on the content.
        
        // Additional cleanup for other UI components or resources if necessary.
        // This could include resetting layout constraints, stopping animations,
        // or clearing any cached data that's specific to the content of this view.
    }

}
