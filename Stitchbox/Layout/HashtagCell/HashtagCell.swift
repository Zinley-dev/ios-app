//
//  HashtagCell.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/2/21.
//

import UIKit

// MARK: - HashtagCell Class
// This class represents a custom UICollectionViewCell for displaying a hashtag.

class HashtagCell: UICollectionViewCell {
    
    // MARK: - Properties
    // Flag to indicate whether the height has been calculated, useful for dynamic cell sizing.
    var isHeightCalculated: Bool = false

    // MARK: - Outlets
    // Outlet for the label that displays the hashtag.
    @IBOutlet weak var hashTagLabel: UILabel!
    
    // MARK: - Nib Registration
    // Returns a UINib object initialized to the nib file in the specified bundle.
    static func nib() -> UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
    
    // Returns a string that can be used as a reuse identifier for the cell.
    static func cellReuseIdentifier() -> String {
        return String(describing: self)
    }
    
    // MARK: - Cell Configuration
    // Configures the cell with model data.
    func setModel() {
        // Set the text for the hashtag label.
        hashTagLabel.text = "Hashtag"
        // Here, you can modify to accept a parameter with the actual hashtag text
        // and set it to the label.
    }

}
