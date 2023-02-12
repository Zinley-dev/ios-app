//
//  TwoFactorAuthVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/18/23.
//

import UIKit

class TwoFactorAuthVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    var settings: SettingModel!
    
    
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

                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
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
                            self.showErrorAlert("Oops!", msg: "This phone may has been registered")
                            
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
                        self.showErrorAlert("Oops!", msg: "Cannot turn on your 2fa and this time, please try again")
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

                case .failure(let error):
                    print(error)
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
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
                            self.showErrorAlert("Oops!", msg: "This email may has been registered")
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
                        self.showErrorAlert("Oops!", msg: "Cannot turn on your 2fa and this time, please try again")
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
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Two-Factor Authentication", for: .normal)
        backButton.sizeToFit()
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
        
        if self.settings != nil {
            if self.settings.EnableEmailTwoFactor == true {
                self.EmailSwitch.setOn(true, animated: true)
                isEmail = true
            } else {
                self.EmailSwitch.setOn(false, animated: true)
                isEmail = false
            }
            
            if self.settings.EnablePhoneTwoFactor == true {
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
