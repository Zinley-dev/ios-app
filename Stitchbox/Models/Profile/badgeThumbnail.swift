//
//  badgeThumbnail.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/20/23.
//

import Foundation
import UIKit

struct badgeThumbnail {
    let id = UUID()
    let image: UIImage
}

extension badgeThumbnail: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension badgeThumbnail {
    static var demoPhotos: [badgeThumbnail] {
        let names = (1...16).map({ "b\($0)" })
        
        return names.map({ badgeThumbnail(image: UIImage(named: $0)!) })
    }
}
