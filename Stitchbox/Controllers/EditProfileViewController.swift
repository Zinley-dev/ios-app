//
//  EditProfileViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/24/22.
//

import RxCocoa
import RxSwift
import EzPopup

class EditProfileViewController: UIViewController, ControllerType {
    
    
    typealias ViewModelType = EditProfileViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        setUpNavigationBar()
        viewModel.getAPISetting()
        presentLoading()
    }
    func bindUI(with viewModel: EditProfileViewModel) {
    
    }
    
    func bindAction(with viewModel: EditProfileViewModel) {
        
    }
    
    // MARK: - UI
    @IBAction func changeProfileImage() {
//        let viewCtrl = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EDITPROFILEPHOTO")
//        let popupVC =  PopupViewController(contentController: viewCtrl, position: .bottomLeft(CGPoint(x: 0, y: UIScreen.main.bounds.minY)), popupWidth: nil, popupHeight: nil)
//        
//        popupVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
//        popupVC.shadowEnabled = true
//        
//        self.present(popupVC, animated: true)
        
        
        
    }
    
    @IBAction func changeCoverImage() {
        
    }
    
    @IBAction func editInfo() {
        
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


