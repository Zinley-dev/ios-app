//
//  Color.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/25/22.
//
import Foundation
import UIKit

extension UIColor{
 
    class var chatBackGround: UIColor{
        return UIColor(red: (51/255.0), green: (47.0/255.0), blue: (48.0/255.0), alpha: 1.0)
    }
    
    class var navigationBarColor: UIColor{
        return UIColor.black
    }
  
      class var secondary: UIColor{
        return UIColor(red: (255.0/255.0), green: (69.0/255.0), blue: (0/255.0), alpha: 1.0)
      }
      
      class var tertiary: UIColor{
          return white
      }
    
    class var disableButtonBackground: UIColor{
        return UIColor(red: (131.0/255.0), green: (134.0/255.0), blue: 139.0/255.0, alpha: 1.0)
    }
  
  class var text: UIColor{
    return UIColor{ traitCollection in
      // 2
      switch traitCollection.userInterfaceStyle {
          //            case .light:
          //                return UIColor(red: (58.0/255.0), green: (60.0/255.0), blue: (64.0/255.0), alpha: 1.0)
        default:
          return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
      }
    }
  }
  
  class var disabled: UIColor{
    return UIColor(red: (187.0/255.0), green: (187.0/255.0), blue: (187.0/255.0), alpha: 1.0)
  }
  
  class var background: UIColor{
    return UIColor{ traitCollection in
      switch traitCollection.userInterfaceStyle {
          //            case .light:
          //                return UIColor(red: (255.0/255.0), green: (255.0/255.0), blue: (255.0/255.0), alpha: 1.0)
        default:
          return .black
      }
    }
  }
  class var other: UIColor{
    return UIColor(red: (245.0/255.0), green: (245.0/255.0), blue: (245.0/255.0), alpha: 1.0)
  }
  class var tabbar: UIColor{
    return UIColor{ traitCollection in
      // 2
      switch traitCollection.userInterfaceStyle {
          //            case .light:
          //                return UIColor(red: (53.0/255.0), green: (46.0/255.0), blue: (113.0/255.0), alpha: 1.0)
        default:
          return .black
      }
    }
  }
  
  class var tabbarbackground: UIColor{
    return UIColor{ traitCollection in
      // 2
      switch traitCollection.userInterfaceStyle {
          //                case .light:
          //                    return UIColor(red: (255.0/255.0), green: (255.0/255.0), blue: (255.0/255.0), alpha: 1.0)
        default:
          return .black
      }
    }
    //    class var gradientColor: CGGradient {
    //        return CGGradient(colorsSpace: .init(name: CFString("RGB")), colors: ["#rgba(254, 128, 92, 1)", "rgba(53, 46, 113, 1)"] as CFArray, locations: .Stride())!
    //    }
  }
  
}
