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
            ImageExporter.shared.export(image: image, completion: {
                (error, exportedImage) in
                if let error = error {
                    self.presentErrorAlert(message: "Unable to export image: \(error)")
                    return
                }
                switch self.currentMode {
                case .changeAvatar:
                    APIManager().uploadavatar(image: exportedImage!) {
                        result in switch result {
                            
                        case .success(let message):
                            print(message)
                            DispatchQueue.main.async {
                                self.presentMessage(message: "Success upload image")
                            }
                        case .failure(let error):
                            print(error)
                            DispatchQueue.main.async {
                                self.presentError(error: error)
                            }
                        }
                    }
                case .changeCover:
                    APIManager().uploadcover(image: exportedImage!) {
                        result in switch result {
                            
                        case .success(let message):
                            print(message)
                            DispatchQueue.main.async {
                                self.presentMessage(message: "Success upload image")
                            }
                        case .failure(let error):
                            print(error)
                            DispatchQueue.main.async {
                                self.presentError(error: error)
                            }
                        }
                    }
                }
                
            })
        }
        
        self.dismiss(animated: true)
    }
    
    func changeImage() {
        let container = ContainerController(modes: [.library, .photo])
        container.editControllerDelegate = self
        
        // include only Image from the users photo
        container.libraryController.fetchPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        // include only Image from the users drafts
        container.libraryController.draftMediaTypes =
        [.image]
        
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
}
