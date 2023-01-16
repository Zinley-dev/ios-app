//
//  InstantiatesFromNib.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 01/08/22.
//

import UIKit

protocol InstantiatesFromNib: AnyObject {
    func setupView()
}

extension InstantiatesFromNib where Self: UIView {
    static var nib: UINib {
        return UINib(nibName: String(describing: Self.self), bundle: nil)
    }
    
    static func instanceFromNib() -> Self {
        let view = nib.instantiate(withOwner: nil, options: nil)[0] as! Self
        view.setupView()
        return view
    }
    
    func setupView() {
    }
}
