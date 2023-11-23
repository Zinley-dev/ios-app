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
    
    private var actionButton: UIButton = UIButton() // Renamed for clarity
    private var cachedResizedImage: UIImage? // Caching resized image for performance

    // Enum to define tab bar types with associated colors
    enum TabBarType {
        case black
        case white
        
        var color: UIColor {
            switch self {
            case .black: return .black
            case .white: return .white
            }
        }
    }
    
    // MARK: - Setup Methods

    /// Sets up the middle button in the tab bar with specified type.
    /// - Parameter tabBarType: The type of the tab bar (black/white).
    func setupMiddleButton(for tabBarType: TabBarType) {
        configureButtonAppearance(for: tabBarType)
        positionMiddleButton()
        addActionToButton()
        verifyButtonFitInTabBar()
    }

    // MARK: - Private Methods

    /// Configures the appearance of the action button based on tab bar type.
    private func configureButtonAppearance(for tabBarType: TabBarType) {
        actionButton.setImage(nil, for: .normal) // Clear any previous image
        actionButton.backgroundColor = tabBarType.color
        
        if tabBarType == .white, cachedResizedImage == nil {
            cachedResizedImage = UIImage(named: "Add 2")?.resize(targetSize: CGSize(width: 26, height: 26))
        }
        actionButton.setImage(cachedResizedImage, for: .normal)
    }

    /// Positions the action button in the middle of the tab bar.
    private func positionMiddleButton() {
        guard actionButton.superview == nil else { return }

        let tabBarHeight = self.tabBar.frame.height
        let buttonSize = CGSize(width: 30.5, height: 30.5)
        let buttonFrame = CGRect(
            x: (self.tabBar.frame.width / 2) - (buttonSize.width / 2),
            y: (tabBarHeight - buttonSize.height) / 2,
            width: buttonSize.width,
            height: buttonSize.height
        )
        actionButton.frame = buttonFrame
        self.tabBar.addSubview(actionButton)
    }

    /// Adds an action to the button.
    private func addActionToButton() {
        actionButton.addTarget(self, action: #selector(pressedAction(_:)), for: .touchUpInside)
        actionButton.layer.zPosition = 2500
    }

    /// Verifies that the action button fits within the tab bar.
    private func verifyButtonFitInTabBar() {
        let tabBarHeight = self.tabBar.frame.height
        let buttonSize = CGSize(width: 30.5, height: 30.5)
        if buttonSize.height > tabBarHeight {
            print("Warning: Button size is larger than the tab bar height. Button may not fit properly.")
        }
    }
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        SBDMain.add(self, identifier: self.sbu_className)

        setUserProfileImageOnTabbar()
        setupMiddleButton(for: .black)
        setupBlackTabBar()
    }

    // MARK: - Tab Bar Configuration

    func setupBlackTabBar() {
        configureTabBarAppearance(backgroundColor: .black, iconColor: .black)
        setupImageForTabbar()
        updateMiddleButtonImage(named: "Add 2", size: CGSize(width: 26, height: 26))
    }

    func setupWhiteTabBar() {
        configureTabBarAppearance(backgroundColor: .white, iconColor: .white)
        setupImageForTabbar(isLight: true)
        updateMiddleButtonImage(named: "Add 3", size: CGSize(width: 26, height: 26))
    }

    // MARK: - Helpers

    private func configureTabBarAppearance(backgroundColor: UIColor, iconColor: UIColor) {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = backgroundColor
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = iconColor
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = iconColor
        self.tabBar.standardAppearance = tabBarAppearance
        self.view.backgroundColor = backgroundColor
    }

    private func updateMiddleButtonImage(named imageName: String, size: CGSize) {
        actionButton.setImage(UIImage(named: imageName)?.resize(targetSize: size), for: .normal)
    }

    // MARK: - Button Action

    @objc func pressedAction(_ sender: UIButton) {
        self.selectedIndex = 2
        presentPostVC()
    }

    
    // MARK: - Image Caching

    private var imageCache = [String: UIImage]()

    /// Retrieves an image from the cache or creates it if not present.
    /// - Parameters:
    ///   - named: The name of the image.
    ///   - targetSize: The target size for the image.
    /// - Returns: The cached or newly resized image.
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

    // MARK: - Setup Tab Bar Images

    /// Sets up tab bar images depending on the specified mode (light or default).
    /// - Parameter isLight: A boolean indicating if the light mode is active.
    func setupImageForTabbar(isLight: Bool = false) {
        guard let items = tabBar.items, items.count > 3 else {
            print("Insufficient tab bar items.")
            return
        }
        
        let names: [Int: (String, String)] = isLight ? [
            0: ("home-unfill-black", "home-filled-black"),
            1: ("trending-unfilled-black", "trending-filled-black"),
            3: ("chat-black", "chat-filled-black")
        ] : [
            0: ("home", "home.filled"),
            1: ("trendingWhite", "trendingFilled"),
            3: ("chat", "chat.filled")
        ]
        
        for (index, (unfilledName, filledName)) in names {
            let size = index == 0 ? CGSize(width: 28, height: 28) : CGSize(width: 25, height: 25)
            
            if let normalImage = cachedImage(named: unfilledName, targetSize: size),
               let selectedImage = cachedImage(named: filledName, targetSize: size) {
                items[index].image = normalImage
                items[index].selectedImage = selectedImage
            } else {
                print("Error: Image not found for \(unfilledName) or \(filledName)")
            }
        }
    }


    // MARK: - Setup Tab Bar Images for Light Mode

    /// Sets up tab bar images for light mode.
    func setupImageForTabbarLightMode() {
        guard let items = tabBar.items, items.count >= 4 else {
            print("Insufficient tab bar items.")
            return
        }

        // Setup images for the first, second, and fourth tab bar items.
        items[0].setupTabBarItemImages(normalImageName: "home", selectedImageName: "home.filled")
        items[1].setupTabBarItemImages(normalImageName: "trendingWhite", selectedImageName: "trendingFilled")
        items[3].setupTabBarItemImages(normalImageName: "chat", selectedImageName: "chat.filled")
    }

    // MARK: - Custom Image Creation

    /// Creates a custom image view with a circular border for normal state.
    /// - Parameter image: The original image to modify.
    /// - Returns: A circular, bordered image.
    func createCustomImageView(with image: UIImage) -> UIImage {
        let circularImage = image.circularImage(size: CGSize(width: 32.5, height: 32.5))
        return circularImage.withBorder(width: 1.0, color: .black).withRenderingMode(.alwaysOriginal)
    }

    /// Creates a custom image view with a circular border for selected state.
    /// - Parameter image: The original image to modify.
    /// - Returns: A circular, bordered image.
    func createCustomSelectedImageView(with image: UIImage) -> UIImage {
        let circularImage = image.circularImage(size: CGSize(width: 32.5, height: 32.5))
        return circularImage.withBorder(width: 1.0, color: .secondary).withRenderingMode(.alwaysOriginal)
    }


    // MARK: - Set User Profile Image on Tab Bar

    /// Sets the user's profile image on the last tab bar item.
    func setUserProfileImageOnTabbar() {
        guard let items = tabBar.items, let lastItem = items.last else { return }

        // Check for user's image URL.
        if let userImageUrl = _AppCoreData.userDataSource.value?.avatarURL, !userImageUrl.isEmpty {
            // Fetch or load the user's profile image.
            fetchUserProfileImage(userImageUrl, for: lastItem)
        } else {
            // Set a default image if the URL is not available.
            setDefaultImageForTabBarItem(lastItem)
        }
    }

    /// Fetches the user's profile image from cache or network.
    /// - Parameters:
    ///   - url: The URL of the user's profile image.
    ///   - tabBarItem: The tab bar item to set the image on.
    private func fetchUserProfileImage(_ url: String, for tabBarItem: UITabBarItem) {
        CacheManager.shared.fetchImage(forKey: url) { [weak self] cachedImage in
            if let image = cachedImage {
                self?.setTabBarItem(tabBarItem, with: image)
            } else {
                // Fetch image from network if not available in cache.
                self?.fetchImageFromNetwork(url, for: tabBarItem)
            }
        }
    }

    /// Fetches an image from the network.
    /// - Parameters:
    ///   - url: The URL to fetch the image from.
    ///   - tabBarItem: The tab bar item to set the image on.
    private func fetchImageFromNetwork(_ url: String, for tabBarItem: UITabBarItem) {
        AF.request(url).responseImage { [weak self] response in
            switch response.result {
            case .success(let image):
                // Set the fetched image on the tab bar item.
                self?.setTabBarItem(tabBarItem, with: image)
                // Cache the fetched image.
                CacheManager.shared.storeImage(forKey: url, image: image)
            case .failure:
                // Set a default image in case of failure.
                self?.setDefaultImageForTabBarItem(tabBarItem)
            }
        }
    }

    /// Sets the tab bar item with the provided image.
    /// - Parameters:
    ///   - tabBarItem: The tab bar item to set the image on.
    ///   - image: The image to set.
    private func setTabBarItem(_ tabBarItem: UITabBarItem, with image: UIImage) {
        DispatchQueue.main.async {
            let customImage = self.createCustomImageView(with: image)
            let selectedCustomImage = self.createCustomSelectedImageView(with: image)
            
            tabBarItem.image = customImage
            tabBarItem.selectedImage = selectedCustomImage
        }
    }

    /// Sets a default image on the tab bar item.
    /// - Parameter tabBarItem: The tab bar item to set the default image on.
    private func setDefaultImageForTabBarItem(_ tabBarItem: UITabBarItem) {
        let defaultImage = UIImage(named: "defaultuser")!
        setTabBarItem(tabBarItem, with: defaultImage)
    }

    // MARK: - UITabBarControllerDelegate

    /// Determines whether a view controller should be selected.
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        guard let selectedIndex = tabBarController.viewControllers?.firstIndex(of: viewController) else {
            return true
        }

        // Prevent selection of the third tab (index 2).
        return selectedIndex != 2
    }

    
    // MARK: - Unread Messages Handling

    /// Sets the badge value for unread messages count on the tab bar item.
    /// - Parameter totalCount: The total count of unread messages.
    func setUnreadMessagesCount(_ totalCount: UInt) {
        var badgeValue: String? = totalCount == 0 ? nil : (totalCount > 99 ? "99+" : "\(totalCount)")

        if let tabItem = self.tabBar.items?[3] {
            // Update badge and its attributes for the fourth tab item.
            tabItem.badgeColor = SBUColorSet.error400
            tabItem.badgeValue = badgeValue
            tabItem.setBadgeTextAttributes(
                [
                    .foregroundColor: SBUColorSet.ondark01,
                    .font: SBUFontSet.caption4
                ],
                for: .normal
            )
        } else {
            print("No tabs available")
        }
    }

    // MARK: - UITabBarControllerDelegate

    /// Handles actions when a tab bar item is selected.
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        guard let tabBarIndex = viewController.tabBarController?.selectedIndex else { return }

        if tabBarIndex != 2 {
            selectedTabIndex = tabBarIndex
        }

        tabBarIndex == 0 ? setupBlackTabBar() : setupWhiteTabBar()

        // Clear badge value for the selected tab.
        clearBadgeForSelectedTab(in: tabBarController)
    }

    /// Clears the badge value for the selected tab in a tab bar controller.
    /// - Parameter tabBarController: The tab bar controller containing the tabs.
    private func clearBadgeForSelectedTab(in tabBarController: UITabBarController) {
        guard let selectedTabItem = tabBarController.selectedViewController?.tabBarItem,
              let index = tabBarController.tabBar.items?.firstIndex(of: selectedTabItem) else { return }

        tabBarController.tabBar.items?[index].badgeValue = nil
    }

    // MARK: - Presenting View Controller

    /// Presents the PostNavVC view controller.
    func presentPostVC() {
        guard let PNVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PostNavVC") as? PostNavVC else { return }

        PNVC.modalPresentationStyle = .fullScreen
        self.present(PNVC, animated: true)
    }

    
}

// Extension to handle setting up tab bar item images.
extension UITabBarItem {
    func setupTabBarItemImages(normalImageName: String, selectedImageName: String) {
        let normalImage = UIImage(named: normalImageName)?.resize(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)
        let selectedImage = UIImage(named: selectedImageName)?.resize(targetSize: CGSize(width: 25, height: 25)).withRenderingMode(.alwaysOriginal)

        self.image = normalImage
        self.selectedImage = selectedImage
    }
}

// MARK: - SBDUserEventDelegate

extension DashboardTabBarController: SBDUserEventDelegate {

    /// Called when the total unread message count is updated.
    /// - Parameters:
    ///   - totalCount: The total count of unread messages.
    ///   - totalCountByCustomType: A dictionary containing unread counts by custom type, if any.
    func didUpdateTotalUnreadMessageCount(_ totalCount: Int32,
                                          totalCountByCustomType: [String : NSNumber]?) {
        // Update the unread messages count on the tab bar.
        setUnreadMessagesCount(UInt(totalCount))
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
