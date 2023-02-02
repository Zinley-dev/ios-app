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
        button.setImage(UIImage(named: "Add 2"), for: .normal)
        button.backgroundColor = UIColor.tabbarbackground
        button.layer.cornerRadius = 35
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: -6.0)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        self.view.insertSubview(button, aboveSubview: self.tabBar)
        button.addTarget(self, action: #selector(pressedAction(_:)), for: .touchUpInside)
        button.layer.zPosition = 2500
        
        
    }
    @objc func pressedAction(_ sender: UIButton) {
        // do your stuff here
        self.selectedIndex = 2
        presentPostVC()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sizeButton = 70
        // safe place to set the frame of button manually
        button.frame = CGRect.init(x: Int(self.view.bounds.midX) - sizeButton / 2, y: Int(self.tabBar.frame.minY) - sizeButton / 2, width: sizeButton, height: sizeButton)
    }
    func setupView() {
        self.view.bringSubviewToFront(self.tabBar)
        tabBar.layer.opacity = 1
        tabBar.tintColor = .tabbar
        tabBar.barTintColor = .tabbar
        tabBar.backgroundColor = .tabbarbackground
        tabBar.layer.shadowColor = UIColor.black.cgColor
        tabBar.layer.shadowOffset = CGSize(width: 0.0, height: -6.0)
        tabBar.layer.shadowRadius = 4
        tabBar.layer.shadowOpacity = 0.1
        tabBar.layer.maskedCorners = [.layerMinXMinYCorner,.layerMaxXMinYCorner]
        tabBar.layer.masksToBounds = false
        tabBar.layer.cornerRadius = 20
        tabBar.frame.size.height = 70
        tabBar.frame.origin.x = 50
        UITabBar.appearance().isTranslucent = false
        tabBar.layer.zPosition = 2000
        setupMiddleButton()
    }
    
    // MARK: - UI Setup
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        self.delegate = self
        SBDMain.add(self, identifier: self.sbu_className)
        
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
        
        if let index = viewController.tabBarController?.selectedIndex {
            
            if index != 2 {
                
                selectedTabIndex = index
                
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
