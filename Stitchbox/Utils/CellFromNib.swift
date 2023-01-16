//
//  CellFromNib.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 01/08/22.
//

import UIKit

protocol CellFromNib: UICollectionViewCell {
    
}

extension CellFromNib {
    static var nib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
}
