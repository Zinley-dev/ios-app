//
//  TabSwitching.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/4/22.
//

import Foundation
import UIKit
import SwiftUI

@IBDesignable class LoginTabBarController: UITabBarController {
    
    
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        self.navigationItem.hidesBackButton = true
        // fixing position of tab bar
        let width = CGFloat(300)
        let height = CGFloat(30)
        var screenCenterX = CGFloat(0)
        var screenCenterY = CGFloat(0)
        switch UIDevice.current.orientation{
        case .landscapeLeft:
            screenCenterX = UIScreen.main.bounds.height * 0.5
            screenCenterY = UIScreen.main.bounds.width * 0.5
        case .landscapeRight:
            screenCenterX = UIScreen.main.bounds.height * 0.5
            screenCenterY = UIScreen.main.bounds.width * 0.5
        default:
            screenCenterX = UIScreen.main.bounds.width * 0.5
            screenCenterY = UIScreen.main.bounds.height * 0.5
        }
        
        // x position of blue view, left half of the blue view is on the left of the x center point
        let x = screenCenterX - width/2.0
        
        // y position of blue view, top half of the blue view is on top of the y center point
        let y = screenCenterY - height/2.0 - CGFloat(200)
        self.tabBar.frame = CGRect(x: x, y: y, width: width, height: height)
        self.view.backgroundColor = .clear
        
        //customize tab bar appearance
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = .clear
        
        
        
        let tabBarItemAppearance = UITabBarItemAppearance()
        tabBarItemAppearance.selected.titleTextAttributes = [
            NSAttributedString.Key.backgroundColor: UIColor.secondary,
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 20) as Any
        ]
        tabBarItemAppearance.normal.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.text,
            
            NSAttributedString.Key.font: UIFont(name: "Helvetica", size: 20) as Any
        ]
        tabBarItemAppearance.normal.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        tabBar.selectionIndicatorImage = UIImage.imageWithColor(color: .secondary, size: CGSizeMake(155, 44)).withShadow(blur: 3, color: .black)
        
        tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
        tabBarAppearance.configureWithTransparentBackground()
        
        self.tabBar.standardAppearance = tabBarAppearance
        self.tabBar.scrollEdgeAppearance = tabBarAppearance
        self.updateViewConstraints()
    }
    override func viewDidLayoutSubviews() {
        setupView()
        super.viewDidLayoutSubviews()
    }
    
    // MARK: - UI Setup
    override func prepareForInterfaceBuilder() {
        setupView()
        super.prepareForInterfaceBuilder()
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
}


#if canImport(SwiftUI) && DEBUG


struct TabBarViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Components", bundle: nil).instantiateViewController(withIdentifier: "LoginTabBarController")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController;
    
}

@available(iOS 13, *)
struct TabSwitchingView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            TabBarViewControllerRepresentable()
        }
    }
}
#endif

// MARK: UIIamge Extension for creating layouts
extension UIImage {
    class func imageWithColor(color: UIColor, size: CGSize) -> UIImage {
        let rect: CGRect = CGRectMake(0, 0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        color.setFill()
        let path = UIBezierPath(roundedRect: rect, cornerRadius: size.height / 2)
        path.fill()
        
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    /// Returns a new image with the specified shadow properties.
    /// This will increase the size of the image to fit the shadow and the original image.
    func withShadow(blur: CGFloat = 6, offset: CGSize = .zero, color: UIColor = UIColor(white: 0, alpha: 0.8)) -> UIImage {
        
        let shadowRect = CGRect(
            x: offset.width - blur,
            y: offset.height - blur,
            width: size.width + blur * 2 ,
            height: size.height + blur * 2
        )
        
        UIGraphicsBeginImageContextWithOptions(
            CGSize(
                width: max(shadowRect.maxX, size.width) - min(shadowRect.minX, 0),
                height: max(shadowRect.maxY, size.height) - min(shadowRect.minY, 0)
            ),
            false, 0
        )
        
        let context = UIGraphicsGetCurrentContext()!
        
        context.setShadow(
            offset: offset,
            blur: blur,
            color: color.cgColor
        )
        
        draw(
            in: CGRect(
                x: max(0, -shadowRect.origin.x),
                y: max(0, -shadowRect.origin.y),
                width: size.width,
                height: size.height
            )
        )
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        
        UIGraphicsEndImageContext()
        return image
    }
}
