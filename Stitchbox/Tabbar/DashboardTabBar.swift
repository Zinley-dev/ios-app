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

@IBDesignable class DashboardTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    var button: UIButton = UIButton()
    var actionButtonContainerView: UIView!
    
    // TabBarButton – Setup Middle Button
    func setupMiddleButton() {
        // Configure button properties
        button.setImage(UIImage(named: "Add 2")?.resize(targetSize: CGSize(width: 50, height: 50)), for: .normal)
        button.backgroundColor = .clear
        //button.backgroundColor = UIColor.tabbarbackground
 

        // Calculate position
        let tabBarHeight = self.tabBar.frame.height
        let buttonSize = CGSize(width: 50, height: 50)  // Change to desired size of the button
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
        
        self.tabBar.isTranslucent = false
        
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
            
            
            // Customize the navigation bar appearance
            PNVC.navigationBar.barTintColor = .black
            PNVC.navigationBar.tintColor = .white
            PNVC.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            
            
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
