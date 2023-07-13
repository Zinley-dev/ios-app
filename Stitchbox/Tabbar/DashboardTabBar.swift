//
//  DashboardTabBar.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/13/22.
//

import Foundation
import UIKit
import SwiftUI
import RxCocoa
import RxSwift
import CoreMedia
import SendBirdUIKit
import SendBirdCalls
import AlamofireImage
import Cache
import Alamofire

@IBDesignable class DashboardTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var button: UIButton = UIButton()
    var actionButtonContainerView: UIView!
    
    // TabBarButton – Setup Middle Button
      func setupMiddleButton() {
          // Configure button properties
          button.setImage(UIImage(named: "Add 2")?.resize(targetSize: CGSize(width: 32, height: 32)), for: .normal)
          button.backgroundColor = .clear
          //button.backgroundColor = UIColor.tabbarbackground
   

          // Calculate position
          let tabBarHeight = self.tabBar.frame.height
          let buttonSize = CGSize(width: 37.5, height: 37.5)  // Change to desired size of the button
          let buttonFrame = CGRect(x: (self.tabBar.frame.width / 2) - (buttonSize.width / 2),
                                   y: (tabBarHeight - buttonSize.height) / 2,
                                   width: buttonSize.width,
                                   height: buttonSize.height)

          // Apply frame to button
          button.frame = buttonFrame

          self.tabBar.addSubview(button)

          // Add target for button press
          button.addTarget(self, action: #selector(pressedAction(_:)), for: .touchUpInside)

          // Set button layer's z-position
          button.layer.zPosition = 2500

          // If your button is larger than your tab bar, you will have to adjust the size or position accordingly
          if buttonSize.height > tabBarHeight {
              print("Warning: button size is larger than tab bar height. Button will not fit in tab bar.")
          }
          
          
      }


    
    @objc func pressedAction(_ sender: UIButton) {
        // do your stuff here
        self.selectedIndex = 2
        presentPostVC()
        
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //setupView()
        
        self.delegate = self
        setupMiddleButton()
        SBDMain.add(self, identifier: self.sbu_className)
        
        
        // Remove border line
        self.tabBar.shadowImage = UIImage()
        self.tabBar.backgroundImage = UIImage.from(color: .black)  // Assuming .tabbarbackground is your desired color
        self.tabBar.isTranslucent = false
        
        let layer = CALayer()
        layer.backgroundColor = UIColor.black.cgColor // Use your tabBar color here
        layer.frame = CGRect(x: 0, y: -1, width: self.tabBar.frame.width, height: 1)
        self.tabBar.layer.addSublayer(layer)
        setUserProfileImageOnTabbar()
        setupImageForTabbar()
       
        
    }
    
    func setupImageForTabbar() {
        guard let items = tabBar.items else { return }
        
        if items.count > 1 {
            let firstTabBarItem = items[0]
            let secondTabBarItem = items[1]
            let thirdTabBarItem = items[3]
            
            
            let homeImg = UIImage.init(named: "home")?.resize(targetSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal)
            let homefilledImg = UIImage.init(named: "home.filled")?.resize(targetSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal)
            
            let trendingImg = UIImage.init(named: "trendingWhite")?.resize(targetSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal)
            let trendingfilledImg = UIImage.init(named: "trendingFilled")?.resize(targetSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal)
            
            let chatImg = UIImage.init(named: "chat")?.resize(targetSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal)
            let chatfilledImg = UIImage.init(named: "chat.filled")?.resize(targetSize: CGSize(width: 27, height: 27)).withRenderingMode(.alwaysOriginal)
            
            firstTabBarItem.image = homeImg
            firstTabBarItem.selectedImage = homefilledImg
            
            secondTabBarItem.image = trendingImg
            secondTabBarItem.selectedImage = trendingfilledImg
            
            thirdTabBarItem.image = chatImg
            thirdTabBarItem.selectedImage = chatfilledImg
        }
    }

    
    func createCustomImageView(with image: UIImage) -> UIImage {
        let circularImage = image.circularImage(size: CGSize(width: 37.5, height: 37.5))
        let imageWithBorder = circularImage.withBorder(width: 1.0, color: .black)
        return imageWithBorder.withRenderingMode(.alwaysOriginal)
    }
        
    func createCustomSelectedImageView(with image: UIImage) -> UIImage {
        let circularImage = image.circularImage(size: CGSize(width: 37.5, height: 37.5))
        let imageWithBorder = circularImage.withBorder(width: 1.0, color: .secondary)
        return imageWithBorder.withRenderingMode(.alwaysOriginal)
    }



    func setUserProfileImageOnTabbar() {
        guard let items = tabBar.items, let lastItem = items.last else { return }
            
        if _AppCoreData.userDataSource.value?.avatarURL != "" {
            let userImageUrl = _AppCoreData.userDataSource.value?.avatarURL
                
            imageStorage.async.object(forKey: userImageUrl!) { result in
                if case .value(let image) = result {
                    DispatchQueue.main.async { [weak self] in
                        let customImage = self?.createCustomImageView(with: image)
                        let selectedCustomImage = self?.createCustomSelectedImageView(with: image)
                        
                        lastItem.image = customImage
                        lastItem.selectedImage = selectedCustomImage
                    }
                } else {
                    AF.request(userImageUrl!).responseImage { response in
                        switch response.result {
                        case let .success(image):
                            DispatchQueue.main.async { [weak self] in
                                let customImage = self?.createCustomImageView(with: image)
                                let selectedCustomImage = self?.createCustomSelectedImageView(with: image)
                                
                                lastItem.image = customImage
                                lastItem.selectedImage = selectedCustomImage
                            }
                            
                            try? imageStorage.setObject(image, forKey: userImageUrl!, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                          
                        case let .failure(error):
                            print(error)
                            DispatchQueue.main.async { [weak self] in
                                let defaultImage = UIImage(named: "defaultuser")!
                                
                                let customImage = self?.createCustomImageView(with: defaultImage)
                                let selectedCustomImage = self?.createCustomSelectedImageView(with: defaultImage)
                                
                                lastItem.image = customImage
                                lastItem.selectedImage = selectedCustomImage
                            }
                        }
                    }
                }
            }
        } else {
            print("avatar not found")
            let defaultImage = UIImage(named: "defaultuser")!
            
            let customImage = createCustomImageView(with: defaultImage)
            let selectedCustomImage = createCustomSelectedImageView(with: defaultImage)
            
            lastItem.image = customImage
            lastItem.selectedImage = selectedCustomImage
        }
    }

    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }

        if selectedIndex == 2 {
            return false
        }
        
        return true
    }
    
    func setUnreadMessagesCount(_ totalCount: UInt) {
        
        var badgeValue: String?
        
        
        if totalCount == 0 {
            badgeValue = nil
        } else if totalCount > 99 {
            badgeValue = "99+"
        } else {
            badgeValue = "\(totalCount)"
        }
        
    
        if let tabItems = self.tabBar.items {
            // In this case we want to modify the badge number of the third tab:
           
            let tabItem = tabItems[3]
            
            tabItem.badgeColor = SBUColorSet.error400
            tabItem.badgeValue = badgeValue
            tabItem.setBadgeTextAttributes(
                [
                    NSAttributedString.Key.foregroundColor : SBUColorSet.ondark01,
                    NSAttributedString.Key.font : SBUFontSet.caption4
                ],
                for: .normal
            )
            
        } else {
            
            print("No tabs")
            
        }
        
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
        if let tabBarIndex = viewController.tabBarController?.selectedIndex {
            
            if tabBarIndex != 2 {
                
                selectedTabIndex = tabBarIndex
                
            }
            
            if tabBarIndex == 0 {
                
                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "scrollToTop")), object: nil)
                
            }
            
        }
        
        // Get the selected tab bar item and clear the badge value
                if let tabItems = tabBarController.tabBar.items, let selectedTabItem = tabBarController.selectedViewController?.tabBarItem {
                    if let index = tabItems.firstIndex(of: selectedTabItem) {
                        let tabItem = tabItems[index]
                        tabItem.badgeValue = nil
                    }
                }
        
    }
    
    func presentPostVC() {
        
        if let PNVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostNavVC") as? PostNavVC {
            
            PNVC.modalPresentationStyle = .fullScreen
            self.present(PNVC, animated: true)
            
        }
        
    }
    
}

extension DashboardTabBarController: SBDUserEventDelegate{
    func didUpdateTotalUnreadMessageCount(_ totalCount: Int32,
                                          totalCountByCustomType: [String : NSNumber]?)
    {
        self.setUnreadMessagesCount(UInt(totalCount))
        
    
    }
    
}



#if canImport(SwiftUI) && DEBUG


struct DashboardTabBarViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Dashboard", bundle: nil).instantiateInitialViewController()!
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController;
    
}

@available(iOS 13, *)
struct DashboardTabSwitchingView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            DashboardTabBarViewControllerRepresentable()
        }
    }
}
#endif

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img ?? UIImage()
    }
}

extension UIImage {
    func circularImage(size: CGSize?) -> UIImage {
        let newImage = resizeForTabbar(targetSize: size ?? self.size)
        let imageView: UIImageView = UIImageView(image: newImage)
        var layerFrame = CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height)
        
        if newImage.size.width != newImage.size.height {
            let width = min(newImage.size.width, newImage.size.height)
            layerFrame = CGRect(x: 0, y: 0, width: width, height: width)
        }

        imageView.layer.frame = layerFrame
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = layerFrame.width / 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 0.0
        imageView.layer.rasterizationScale = UIScreen.main.scale

        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return self }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return result ?? self
    }
    
    func resizeForTabbar(targetSize: CGSize) -> UIImage {
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height

            // maintain the aspect ratio of the image
            let ratio = max(widthRatio, heightRatio)
            let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)

            let rect = CGRect(origin: .zero, size: newSize)

            UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
            self.draw(in: rect)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return newImage ?? self
        }
    
    func createCustomSelectedImageView(with image: UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 2.0
        imageView.layer.borderColor = UIColor.red.cgColor
        return imageView
    }
    
    
    func imageWithView(in imageView: UIImageView) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, imageView.isOpaque, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            imageView.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }

    func withBorder(width: CGFloat, color: UIColor) -> UIImage {
        let scale = self.scale
        let radius = min(self.size.width, self.size.height) / 2
        let imageSize = CGSize(width: 2 * radius, height: 2 * radius)
        
        UIGraphicsBeginImageContextWithOptions(imageSize, false, scale)
        let imageRect = CGRect(x: 0, y: 0, width: imageSize.width, height: imageSize.height)
        let path = UIBezierPath(ovalIn: imageRect.insetBy(dx: width, dy: width))
        
        path.addClip()
        self.draw(in: imageRect)
        
        color.setStroke()
        path.lineWidth = width * 2 // Multiply by 2 because half of the border will be clipped off by the path.
        path.stroke()
        
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result?.withRenderingMode(.alwaysOriginal) ?? self
    }

}
