//
//  TabBarProfileView.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 6/29/23.
//

import Foundation
import UIKit

class TabBarProfileView: UIView {
// MARK: - Outlets And Variable
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var imageViewPerson: UIImageView!
    // MARK: - Class Level Functions
    class func createInScreenSize() -> TabBarProfileView {
    let view: TabBarProfileView = Bundle.main.loadNibNamed("TabBarProfileView", owner: nil, options: nil)![0] as! TabBarProfileView
    view.contentView.layer.cornerRadius = view.contentView.frame.size.width / 2
    view.imageViewPerson.layer.cornerRadius = view.imageViewPerson.frame.size.width / 2
    return view
    }
}
