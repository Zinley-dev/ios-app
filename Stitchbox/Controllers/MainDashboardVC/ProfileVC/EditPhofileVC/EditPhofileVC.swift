//
//  EditPhofileVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/18/23.
//

import UIKit
import PixelSDK
import Alamofire
import Photos

class EditPhofileVC: UIViewController {
    
    enum updateMedia {
        case avatar
        case cover
    }

    @IBOutlet weak var morePersonalInfoBtn: UIButton!
    @IBOutlet weak var changeCoverPhotoBtn: UIButton!
    @IBOutlet weak var changeProfilePhotoBtn: UIButton!
    
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var discordTxtField: UITextField!
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var nameTxtField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var coverImage: UIImageView!
    
    let backButton: UIButton = UIButton(type: .custom)
    let container = ContainerController(modes: [.library, .photo])
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        container.editControllerDelegate = self
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        delay(0.1) {
            self.discordTxtField.addUnderLine()
            self.nameTxtField.addUnderLine()
            self.bioTextField.addUnderLine()
        }
        
    }
    
    @IBAction func usernameBtnPressed(_ sender: Any) {
        
        if let EGIVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditGeneralInformationVC") as? EditGeneralInformationVC {
            
            EGIVC.type = "Username"
            self.navigationController?.pushViewController(EGIVC, animated: true)
            
        }
        
        
    }
    
    
    @IBAction func nameOnTapped(_ sender: Any) {
        
        if let EGIVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditGeneralInformationVC") as? EditGeneralInformationVC {
            
            EGIVC.type = "Name"
            self.navigationController?.pushViewController(EGIVC, animated: true)
            
        }
        
        
    }
    
    
    
    @IBAction func discordDidPressed(_ sender: Any) {
        
        if let EGIVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditGeneralInformationVC") as? EditGeneralInformationVC {
            
            EGIVC.type = "Discord Link"
            self.navigationController?.pushViewController(EGIVC, animated: true)
            
        }
        
        
    }
    
    
    @IBAction func BioDidPress(_ sender: Any) {
        
        
        if let EBVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditBioVC") as? EditBioVC {
            

            self.navigationController?.pushViewController(EBVC, animated: true)
            
        }
        
    }
    
    @IBAction func MoreInfoOnTap(_ sender: Any) {
        
        if let MPIVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "MorePersonalInfoVC") as? MorePersonalInfoVC {
            self.navigationController?.pushViewController(MPIVC, animated: true)
            
        }
        
    }
    
    
    @IBAction func changeCoverOnTapped(_ sender: Any) {
        
        requestImageUpdateForCover()
        
    }
    
    
    @IBAction func changeProfileImageOnTap(_ sender: Any) {
        
        requestImageUpdateForAvatar()
        
    }
    
    

}

extension EditPhofileVC {
    
    func setupButtons() {
        
        setupBackButton()
        colorButtonLabel()
        setupGesture()
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Edit Profile", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func setupGesture() {
        
        let viewTap = UITapGestureRecognizer(target: self, action: #selector(EditPhofileVC.viewTapped))
        contentView.isUserInteractionEnabled = true
        contentView.addGestureRecognizer(viewTap)
        
    }

    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
    func colorButtonLabel() {
        
        changeProfilePhotoBtn.titleLabel?.textColor = .secondary
        changeCoverPhotoBtn.titleLabel?.textColor = .secondary
        morePersonalInfoBtn.titleLabel?.textColor = .secondary
        
    }

      
    
}

extension EditPhofileVC {
    
    @objc func viewTapped(sender: AnyObject!) {
  
        self.view.endEditing(true)
  
    }
    
}

extension EditPhofileVC {
    
    func requestImageUpdateForAvatar() {
        

        // Include only Image from the users photo library
        container.libraryController.fetchPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        // Include only Image from the users drafts
        container.libraryController.draftMediaTypes = [.image]
        
        container.libraryController.previewCropController.aspectRatio = CGSize(width: 1, height: 1)
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
        
    }
    
    func requestImageUpdateForCover() {
        // Include only Image from the users photo library
        container.libraryController.fetchPredicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.image.rawValue)
        // Include only Image from the users drafts
        container.libraryController.draftMediaTypes = [.image]
        
        container.libraryController.previewCropController.maxRatioForPortraitMedia = CGSize(width: 3, height: 4)
        container.libraryController.previewCropController.maxRatioForLandscapeMedia = CGSize(width: 16, height: 9)
        let nav = UINavigationController(rootViewController: container)
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true, completion: nil)
        
    }
    
    
}

extension EditPhofileVC: EditControllerDelegate {
    
    func editController(_ editController: EditController, didLoadEditing session: PixelSDKSession) {
        // Called after the EditController's view did load.
        
        print("Did load here")
    }
    
    func editController(_ editController: EditController, didFinishEditing session: PixelSDKSession) {
        // Called when the Next button in the EditController is pressed.
        // Use this time to either dismiss the UINavigationController, or push a new controller on.
        
        if let image = session.image {
            
            
            ImageExporter.shared.export(image: image, completion: { (error, uiImage) in
                    if let error = error {
                        self.showErrorAlert("Oops!", msg: "Unable to export image: \(error)")
                        return
                    }
                
                print("Export completed")
                
            })
            
            
        }
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    
    
    func editController(_ editController: EditController, didCancelEditing session: PixelSDKSession?) {
        // Called when the back button in the EditController is pressed.
        
        print("Did cancel load here")
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
