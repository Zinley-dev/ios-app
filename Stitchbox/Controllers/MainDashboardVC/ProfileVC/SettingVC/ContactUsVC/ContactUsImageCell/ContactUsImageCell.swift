//
//  ContactUsImageCell.swift
//  The Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit

class ContactUsImageCell: UICollectionViewCell {
    
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var closeBtn: UIButton!
    
    
    func configureCell(img: UIImage) {
        
        imgView.image = img
        
        
    }
    
}
