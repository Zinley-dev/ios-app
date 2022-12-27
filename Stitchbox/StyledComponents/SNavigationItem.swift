//
//  SNavigationItem.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/19/22.
//

import Foundation
import UIKit

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct NavItemViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PROFILE")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController;
    
}

@available(iOS 13, *)
struct NavBarSwitchingView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            NavItemViewControllerRepresentable()
        }
    }
}
#endif

