//
//  DashboardTabBar.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/13/22.
//

import Foundation
import UIKit
import SwiftUI

@IBDesignable class DashboardTabBarController: UITabBarController {
    
    var button: UIButton = UIButton()
    var actionButtonContainerView: UIView!
    
    
    // MARK: - Initialization
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //        setupView()
        self.setupMiddleButton()
    }
    // TabBarButton – Setup Middle Button
    func setupMiddleButton() {
        button.setImage(UIImage(named: "Add 2"), for: .normal)
        button.backgroundColor = UIColor.tabbarbackground
        button.layer.cornerRadius = 40
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: -6.0)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.1
        self.view.insertSubview(button, aboveSubview: self.tabBar)
        button.addTarget(self, action: #selector(pressedAction(_:)), for: .touchUpInside)

    }
    @objc func pressedAction(_ sender: UIButton) {
        // do your stuff here

    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let sizeButton = 70
        // safe place to set the frame of button manually
        button.frame = CGRect.init(x: Int(self.view.bounds.midX) - sizeButton / 2, y: Int(self.tabBar.frame.minY) - sizeButton / 2, width: sizeButton, height: sizeButton)
    }
    func setupView() {
        self.view.bringSubviewToFront( self.tabBar)
        
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
        tabBar.insertSubview(UIButton(), at: 3)
        
    }
    
    // MARK: - UI Setup
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupMiddleButton()
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
