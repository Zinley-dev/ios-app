//
//  SecurityVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit

class SecurityVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var LoginActivityBtn: UIButton!
    @IBOutlet weak var twoFactorAuthBtn: UIButton!
    @IBOutlet weak var resetPasswordBtn: UIButton!
    
    @IBOutlet weak var deleteAccountBtn: UIButton!
    var isDelete = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        emptyButtonsLbl()
        
        if _AppCoreData.userDataSource.value?.isDelete == true {
            isDelete = true
            deleteAccountBtn.setTitle("Cancel account deletion", for: .normal)
        } else {
            deleteAccountBtn.setTitle("Delete account", for: .normal)
        }
        
        
    }
    
    
    @IBAction func resetPwdBtnPressed(_ sender: Any) {
        
        if let RPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ResetPwdVC") as? ResetPwdVC {
            
            self.navigationController?.pushViewController(RPVC, animated: true)
            
        }
        
    }
    
    
    @IBAction func twoFactorAuthBtnPressed(_ sender: Any) {
        
        if let TFAVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "TwoFactorAuthVC") as? TwoFactorAuthVC {
            self.navigationController?.pushViewController(TFAVC, animated: true)
            
        }
        
    }
    
    @IBAction func loginActivityBtnPressed(_ sender: Any) {
        
        if let LAVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "LoginActivityVC") as? LoginActivityVC {
            self.navigationController?.pushViewController(LAVC, animated: true)
            
        }
        
    }
    
    @IBAction func deleteAccountBtnPressed(_ sender: Any) {
        
        
        if let username = _AppCoreData.userDataSource.value?.userName {
            
            if isDelete {
                
                let alert = UIAlertController(title: "Hey \(username) and welcome back!", message: "If you choose to cancel account deletion request, all of your information is still safe and protected. Nothing needs to be done to keep using all available services at Stitchbox. Let's enjoy and have fun.", preferredStyle: UIAlertController.Style.actionSheet)

                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Confirm to cancel", style: UIAlertAction.Style.destructive, handler: { action in
                    
                    self.requestUndoDeletion()
                    
                   
                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

                self.present(alert, animated: true, completion: nil)
                
                
            } else {
                
                let alert = UIAlertController(title: "Hey \(username)! A quick reminder about your account deletion", message: "If you're considering deleting your Stitchbox account, please remember that you can cancel within 30 days. After that, all your information will be permanently deleted, which may take up to 90 days. We're here to help if you have any issues, and we appreciate your time on our platform.", preferredStyle: UIAlertController.Style.actionSheet)

                // add the actions (buttons)
                alert.addAction(UIAlertAction(title: "Confirm to delete", style: UIAlertAction.Style.destructive, handler: { action in
                    
                
                    self.requestAccountDeletion()
                    
                }))

                alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))

                self.present(alert, animated: true, completion: nil)
                
                
            }
            
        }
        

        
    }
    
    func requestUndoDeletion() {
        
        presentSwiftLoader()
        
        APIManager.shared.undoDeleteMe { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                
                self.isDelete = false
                
                Dispatch.main.async {
                    SwiftLoader.hide()
                    self.deleteAccountBtn.setTitle("Delete account", for: .normal)
                    reloadGlobalSettings()
                }
                
                
              case .failure(let error):
                print(error)
                self.isDelete = true
                Dispatch.main.async {
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: "Unable to remove account deletion request \(error.localizedDescription), please try again")
                }
                
            }
          }
    
    }
    
    func requestAccountDeletion() {
        
        presentSwiftLoader()
        
        APIManager.shared.deleteMe { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(_):
                
                self.isDelete = true
                
                Dispatch.main.async {
                    SwiftLoader.hide()
                    self.deleteAccountBtn.setTitle("Cancel account deletion", for: .normal)
                    reloadGlobalSettings()
                }
                
                
              case .failure(let error):
                print(error)
                self.isDelete = false
                Dispatch.main.async {
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: "Unable to request for account deletion \(error.localizedDescription), please try again")
                }
                
            }
          }
        
    }
    
    
    
}

extension SecurityVC {
    
    func setupButtons() {
        
        setupBackButton()
       
    }
    
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back_icn_white") {
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
        navigationItem.title = "Security"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }
    
    func emptyButtonsLbl() {
        
        LoginActivityBtn.setTitle("", for: .normal)
        twoFactorAuthBtn.setTitle("", for: .normal)
        resetPasswordBtn.setTitle("", for: .normal)
        
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
