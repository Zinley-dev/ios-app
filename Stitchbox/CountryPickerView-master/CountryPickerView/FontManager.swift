//
//  File.swift
//  
//
//  Created by Khoi Nguyen on 7/18/23.
//

import Foundation
import UIKit

class FontManager {
    
    static let shared = FontManager()
    
    private init() {}
    
    enum RobotoStyle: String {
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
    
    func roboto(_ style: RobotoStyle, size: CGFloat) -> UIFont {
        guard let font = UIFont(name: style.rawValue, size: size) else {
            fatalError("Failed to load the \(style.rawValue) font.")
        }
        return font
    }
}
