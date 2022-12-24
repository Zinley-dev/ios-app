//
//  EditProfileViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/24/22.
//

import Foundation
import RxCocoa
import RxSwift

class EditProfileViewController: UIViewController {
    
    
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

struct EditProfileViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EDITPROFILE")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController;
    
}

@available(iOS 13, *)
struct EditProfileSwitchingView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            EditProfileViewControllerRepresentable()
        }
    }
}
#endif


