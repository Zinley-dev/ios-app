//
//  StichBoxFont.swift
//  Stitchbox
//
//  Created by Duy Khang Nguyen Truong on 4/19/23.
//

import Foundation
import UIKit

struct StichBoxFont {
    enum FontType: String {
        case Black = "Roboto-Black"
        case BlackItalic = "Roboto-BlackItalic"
        case Bold = "Roboto-Bold"
        case BoldItalic = "Roboto-BoldItalic"
        case Italic = "Roboto-Italic"
        case Light = "Roboto-Light"
        case LightItalic = "Roboto-LightItalic"
        case Medium = "Roboto-Medium"
        case MediumItalic = "Roboto-MediumItalic"
        case Regular = "Roboto-Regular"
        case Thin = "Roboto-Thin"
        case ThinItalic = "Roboto-ThinItalic"
    }
    
    static func font(type: FontType, size: CGFloat) -> UIFont{
        return UIFont(name: type.rawValue, size: size)!
    }
}


