//
//  postThumbnail.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/15/23.
//

import Foundation

import UIKit

struct postThumbnail {
    let id = UUID()
    let image: UIImage
}

extension postThumbnail: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension postThumbnail {
    static var demoPhotos: [postThumbnail] {
        let names = (1...8).map({ "photo\($0)" })
        
        return names.map({ postThumbnail(image: UIImage(named: $0)!) })
    }
}
