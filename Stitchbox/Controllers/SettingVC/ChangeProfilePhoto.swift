////
////  ChangeProfilePhoto.swift
////  Stitchbox
////
////  Created by Khanh Duy Nguyen on 12/29/22.
////
//
import Foundation
import RxSwift
import PixelSDK
import Photos

class ChangePhotoViewController: UIViewController, EditControllerDelegate {
    enum Mode {
         case changeAvatar
         case changeCover
    }
    
    var currentMode : Mode = .changeAvatar
    
    
    @IBAction func changeAvatar() {
        currentMode = .changeAvatar
        changeImage()
    }
    
    @IBAction func changeCover() {
        currentMode = .changeCover
        changeImage()
    }
    

    @IBAction func dismissViewController() {
        dismiss(animated: true)
    }
    
    func editController(_ editController: EditController, didFinishEditing session: Session) {
        
        if let image = session.image {
            print(image)
        }
        
        self.dismiss(animated: true)
    }
    
    func changeImage() {
        let container = ContainerController(modes: [.library, .photo])
        container.editControllerDelegate = self
        
        // include only Image from the users photo
        container.libraryController.fetchPredicate = NSPredicate(format: "mediatype == %d", PHAssetMediaType.image.rawValue)
        // include only Image from the users drafts
        container.libraryController.draftMediaTypes =
        [.image]
        
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
    }

    
    
    
    
   
    
}
//
//
//#if canImport(SwiftUI) && DEBUG
//import SwiftUI
//
//struct EditProfileViewControllerRepresentable: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> UIViewController {
//        return UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EDIT")
//    }
//    
//    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
//        
//    }
//    
//    typealias UIViewControllerType = UIViewController;
//    
//}
//
//@available(iOS 13, *)
//struct EditProfileSwitchingView_Preview: PreviewProvider {
//    static var previews: some View {
//        // view controller using programmatic UI
//        VStack{
//            EditProfileViewControllerRepresentable()
//        }
//    }
//}
//#endif
//
//
