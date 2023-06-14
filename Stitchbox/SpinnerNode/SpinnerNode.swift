//
//  SpinnerNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 6/9/23.
//

import Foundation
import AsyncDisplayKit


class SpinnerNode: ASCellNode {
    let activityIndicator = UIActivityIndicatorView(style: .medium)

    override init() {
        super.init()
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }

    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let centerSpec = ASCenterLayoutSpec(centeringOptions: .XY, sizingOptions: [], child: self)
        return centerSpec
    }
}
