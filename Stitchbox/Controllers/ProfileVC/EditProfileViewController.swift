//
//  EditProfileViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/24/22.
//

import Foundation
import RxCocoa
import RxSwift

class EditProfileViewController: UIViewController, ControllerType {
    
    
    typealias ViewModelType = ProfileViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        setUpNavigationBar()
        presentLoading()
    }
    func bindUI(with viewModel: ProfileViewModel) {
    
    }
    
    func bindAction(with viewModel: ProfileViewModel) {
        
    }
    
    // MARK: - UI
    @IBOutlet var ChangeProfileImageLabel: UILabel?
    @IBOutlet var ChangeCoveImageLabel: UILabel?
    @IBAction func EditInfo() {
        
    }
    
    @IBAction func resetPasswordButton() {
        
    }
    

    
    
   
    
}


#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct EditProfileViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EDIT")
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


