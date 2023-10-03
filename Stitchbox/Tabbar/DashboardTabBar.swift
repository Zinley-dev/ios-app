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
    enum TabBarType {
        case black
        case white
    }

    private var cachedResizedImage: UIImage?

    func setupMiddleButton(for tabBarType: TabBarType) {
        switch tabBarType {
        case .black:
            button.setImage(nil, for: .normal) // Clear any previous image
            button.backgroundColor = .clear
        case .white:
            if cachedResizedImage == nil {
                cachedResizedImage = UIImage(named: "Add 2")?.resize(targetSize: CGSize(width: 32, height: 32))
            }
            button.setImage(cachedResizedImage, for: .normal)
            button.backgroundColor = .clear
        }
        
        positionMiddleButton()
        button.addTarget(self, action: #selector(pressedAction(_:)), for: .touchUpInside)
        button.layer.zPosition = 2500
        checkButtonFitInTabBar()
    }

    private func positionMiddleButton() {
        // Only calculate if the button hasn't been added yet
        if button.superview == nil {
            let tabBarHeight = self.tabBar.frame.height
            let buttonSize = CGSize(width: 37.5, height: 37.5)
            let buttonFrame = CGRect(
                x: (self.tabBar.frame.width / 2) - (buttonSize.width / 2),
                y: (tabBarHeight - buttonSize.height) / 2,
                width: buttonSize.width,
                height: buttonSize.height
            )
            button.frame = buttonFrame
            self.tabBar.addSubview(button)
        }
    }

    private func checkButtonFitInTabBar() {
        let tabBarHeight = self.tabBar.frame.height
        let buttonSize = CGSize(width: 37.5, height: 37.5)
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
        
        SBDMain.add(self, identifier: self.sbu_className)

        setUserProfileImageOnTabbar()
        
        setupMiddleButton(for: .black)
        setupBlackTabBar()
        
         
    }
    
    func setupBlackTabBar() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .black
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .black
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .black
        self.tabBar.standardAppearance = tabBarAppearance
        self.view.backgroundColor = .black
        setupImageForTabbar()
        button.setImage(UIImage(named: "Add 2")?.resize(targetSize: CGSize(width: 32, height: 32)), for: .normal)
    }

   
    func setupWhiteTabBar() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = .white
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = .white
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = .white
        self.tabBar.standardAppearance = tabBarAppearance
        self.view.backgroundColor = .white
        setupImageForTabbar(isLight: true)
        button.setImage(UIImage(named: "Add 3")?.resize(targetSize: CGSize(width: 32, height: 32)), for: .normal)
    }
    
    // Create an image cache
    private var imageCache = [String: UIImage]()

    // Function to retrieve an image from the cache or create it if not present
    private func cachedImage(named: String, targetSize: CGSize) -> UIImage? {
        let cacheKey = "\(named)-\(targetSize.width)x\(targetSize.height)"
        if let cached = imageCache[cacheKey] {
            return cached
        } else if let image = UIImage(named: named)?.resize(targetSize: targetSize).withRenderingMode(.alwaysOriginal) {
            imageCache[cacheKey] = image
            return image
        }
        return nil
    }

    func setupImageForTabbar(isLight: Bool = false) {
        guard let items = tabBar.items, items.count > 3 else { return }
        
        let names: [Int: (String, String)]
        if isLight {
            names = [
                0: ("home-unfill-black", "home-filled-black"),
                1: ("trending-unfilled-black", "trending-filled-black"),
                3: ("chat-black", "chat-filled-black")
            ]
        } else {
            names = [
                0: ("home", "home.filled"),
                1: ("trendingWhite", "trendingFilled"),
                3: ("chat", "chat.filled")
            ]
        }
        
        for (index, (unfilledName, filledName)) in names {
            let size = index == 0 ? CGSize(width: 30, height: 30) : CGSize(width: 27, height: 27)
            
            items[index].image = cachedImage(named: unfilledName, targetSize: size)!.withRenderingMode(.alwaysOriginal)
            items[index].selectedImage = cachedImage(named: filledName, targetSize: size)!.withRenderingMode(.alwaysOriginal)
        }
    }




    
    func setupImageForTabbarLightMode() {
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

        if let userImageUrl = _AppCoreData.userDataSource.value?.avatarURL, !userImageUrl.isEmpty {
            
            CacheManager.shared.fetchImage(forKey: userImageUrl) { [weak self] cachedImage in
                if let image = cachedImage {
                    DispatchQueue.main.async {
                        let customImage = self?.createCustomImageView(with: image)
                        let selectedCustomImage = self?.createCustomSelectedImageView(with: image)
                        
                        lastItem.image = customImage
                        lastItem.selectedImage = selectedCustomImage
                    }
                } else {
                    AF.request(userImageUrl).responseImage { [weak self] response in
                        switch response.result {
                        case .success(let image):
                            DispatchQueue.main.async {
                                let customImage = self?.createCustomImageView(with: image)
                                let selectedCustomImage = self?.createCustomSelectedImageView(with: image)
                                
                                lastItem.image = customImage
                                lastItem.selectedImage = selectedCustomImage
                            }
                            
                            CacheManager.shared.storeImage(forKey: userImageUrl, image: image)
                        case .failure(let error):
                            print(error)
                            DispatchQueue.main.async {
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
                setupBlackTabBar()
            } else {
                setupWhiteTabBar()
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
