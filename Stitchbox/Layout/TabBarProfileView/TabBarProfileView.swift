//
//  TabBarProfileView.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 6/29/23.
//

import Foundation
import UIKit

// MARK: - TabBarProfileView Class
// This class represents a custom view for displaying a profile picture, typically used in a tab bar.

class TabBarProfileView: UIView {
    // MARK: - Outlets
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageViewPerson: UIImageView!

    // MARK: - Class Level Functions
    // Creates and returns an instance of TabBarProfileView, configured with rounded corners.
    class func createInScreenSize() -> TabBarProfileView {
        // Load the view from the XIB file.
        let view: TabBarProfileView = Bundle.main.loadNibNamed("TabBarProfileView", owner: nil, options: nil)![0] as! TabBarProfileView
        
        // Apply corner radius to make the contentView and imageViewPerson circular.
        view.contentView.layer.cornerRadius = view.contentView.frame.size.width / 2
        view.imageViewPerson.layer.cornerRadius = view.imageViewPerson.frame.size.width / 2
        
        // Return the configured view.
        return view
    }
}
