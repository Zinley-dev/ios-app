//
//  SupportVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/11/23.
//

import UIKit

class SupportVC: UIViewController {
    
    let backButton: UIButton = UIButton(type: .custom)

    @IBOutlet weak var contactUsBtn: UIButton!
    @IBOutlet weak var resolutionCenterBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
    }
    
    
    @IBAction func contactUsBtnPressed(_ sender: Any) {
        
        if let CUVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ContactUsVC") as? ContactUsVC {
            
            self.navigationController?.pushViewController(CUVC, animated: true)
            
        }
        
    }
    
    
    @IBAction func resolutionCenterBtnPressed(_ sender: Any) {
        
        if let CUVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ResolutionVC") as? ResolutionVC {
            
            self.navigationController?.pushViewController(CUVC, animated: true)
            
        }
        
    }
    

}

extension SupportVC {
    
    func setupButtons() {
        
        setupBackButton()
       
    }
    
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back-black") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        navigationItem.title = "Your support"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }
    
    func emptyButtonsLbl() {
        
        contactUsBtn.setTitle("", for: .normal)
        resolutionCenterBtn.setTitle("", for: .normal)
       
        
    }

    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
}
