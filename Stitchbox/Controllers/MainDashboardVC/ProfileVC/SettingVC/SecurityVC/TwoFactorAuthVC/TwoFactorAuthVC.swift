//
//  TwoFactorAuthVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/18/23.
//

import UIKit

class TwoFactorAuthVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
   
    
    
    var isPhone = false
    var isEmail = false
    
    
    @IBOutlet weak var PhoneSwitch: UISwitch!
    @IBOutlet weak var EmailSwitch: UISwitch!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        processDefaultData()
        
    }
    
    
    @IBAction func PhoneSwitchPressed(_ sender: Any) {
        
        if isPhone {
            isPhone = false
            presentSwiftLoader()
            APIManager().turnOff2fa(method: "phone") { result in
                switch result {
                case .success(let apiResponse):
                    
                    print(apiResponse)
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                    }
                    reloadGlobalSettings()

                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        self.showErrorAlert("Oops!", msg: "Cannot turn off your 2fa and this time, please try again")
                        SwiftLoader.hide()
                        self.PhoneSwitch.setOn(true, animated: true)
                    }
                }
            }
            
            
        } else {
            isPhone = true
            presentSwiftLoader()
            APIManager().turnOn2fa(method: "phone") { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "OTP sent" else {
                        
                        DispatchQueue.main.async {
                            SwiftLoader.hide()
                            self.showErrorAlert("Oops!", msg: "This phone may has already been registered")
                            self.PhoneSwitch.setOn(false, animated: true)
                            
                        }
                        
                        return
                    }
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.moveToVerifyVC(selectedType: "2FA - phone")
                    }

                case .failure(let error):
                    self.isPhone = false
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Cannot turn on your 2fa and this time, please make sure you have your phone ready and try again.")
                        self.PhoneSwitch.setOn(false, animated: true)
                    }
                  
                    print(error)
                }
            }
            
            
        }
        
        
    }
    
    
    @IBAction func EmailSwitchPressed(_ sender: Any) {
        
        if isEmail {
            isEmail = false
            presentSwiftLoader()
            APIManager().turnOff2fa(method: "email") { result in
                switch result {
                case .success(let apiResponse):
                    
                    print(apiResponse)
                    reloadGlobalSettings()

                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Cannot turn off your 2fa and this time, please make sure you have your email ready and try again.")
                        self.EmailSwitch.setOn(true, animated: true)
                        
                    }
                }
            }
    
            
        } else {
            isEmail = true
            presentSwiftLoader()
            APIManager().turnOn2fa(method: "email") { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "OTP sent" else {
                        
                        DispatchQueue.main.async {
                            SwiftLoader.hide()
                            self.showErrorAlert("Oops!", msg: "This email may has already been registered")
                            self.EmailSwitch.setOn(false, animated: true)
                        }
                        
                        return
                    }
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.moveToVerifyVC(selectedType: "2FA - email")
                    }

                case .failure(let error):
                    self.isEmail = false
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Cannot turn on your 2fa and this time, please make sure you have your email ready and try again.")
                        self.EmailSwitch.setOn(false, animated: true)
                    }
                  
                    print(error)
                }
            }
            
            
        }
        
        
    }
    
    
    func moveToVerifyVC(selectedType: String) {
        
        if let VCVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "VerifyCodeVC") as? VerifyCodeVC {
            
            VCVC.type = selectedType
            self.navigationController?.pushViewController(VCVC, animated: true)
            
        }
        
    }


}

extension TwoFactorAuthVC {
    
    func setupButtons() {
        
        setupBackButton()
       
    }
    
    func setupBackButton() {
        //Two-Factor Authentication

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
        navigationItem.title = "Two-Factor Authentication"
       
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
  

    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}

extension TwoFactorAuthVC {
    
    func processDefaultData() {
        
        if globalSetting != nil {
            if globalSetting.EnableEmailTwoFactor == true {
                self.EmailSwitch.setOn(true, animated: true)
                isEmail = true
            } else {
                self.EmailSwitch.setOn(false, animated: true)
                isEmail = false
            }
            
            if globalSetting.EnablePhoneTwoFactor == true {
                self.PhoneSwitch.setOn(true, animated: true)
                isPhone = true
            } else {
                self.PhoneSwitch.setOn(false, animated: true)
                isPhone = false
            }
           
            
        }
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
}
