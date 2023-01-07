//
//  ReferralCodeViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/24/22.
//

import Foundation
import RxCocoa
import RxSwift

class ReferralCodeViewController: UIViewController {
    
    
    // MARK: - UI
    @IBOutlet var ReferralTextField: UITextField?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        print()
    }
    
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct ReferralCodeViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "REFERRAL")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController;
    
}

@available(iOS 13, *)
struct ReferralCodeSwitchingView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            ReferralCodeViewControllerRepresentable()
        }
    }
}
#endif


