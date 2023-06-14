//
//  MorePersonalInfoVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/18/23.
//

import UIKit

class MorePersonalInfoVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var birthdayTxtField: UITextField!
    @IBOutlet weak var phoneTxtField: UITextField!
    @IBOutlet weak var emailTxtField: UITextField!
    
    var type = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupBackButton()
        
        let birthdayTap = UITapGestureRecognizer(target: self, action: #selector(birthdayTxtFieldTapped))
        birthdayTxtField.isUserInteractionEnabled = true
        birthdayTxtField.addGestureRecognizer(birthdayTap)

        let phoneTap = UITapGestureRecognizer(target: self, action: #selector(phoneTxtFieldTapped))
        phoneTxtField.isUserInteractionEnabled = true
        phoneTxtField.addGestureRecognizer(phoneTap)

        let emailTap = UITapGestureRecognizer(target: self, action: #selector(emailTxtFieldTapped))
        emailTxtField.isUserInteractionEnabled = true
        emailTxtField.addGestureRecognizer(emailTap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDefaultInfo()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        delay(0.1) {
            self.birthdayTxtField.addUnderLine()
            self.phoneTxtField.addUnderLine()
            self.emailTxtField.addUnderLine()
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    
    @objc func birthdayTxtFieldTapped() {
        if let EGIVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditBirthdayVC") as? EditBirthdayVC {
        
            self.navigationController?.pushViewController(EGIVC, animated: true)
            
        }
    }

    @objc func phoneTxtFieldTapped() {
        if let EPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditPhoneVC") as? EditPhoneVC {
            
            self.navigationController?.pushViewController(EPVC, animated: true)
            
        }
    }

    @objc func emailTxtFieldTapped() {
        if let EEVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditEmailVC") as? EditEmailVC {
            
            self.navigationController?.pushViewController(EEVC, animated: true)
            
        }
    }
    
    
    
}


extension MorePersonalInfoVC {
    
    
    func setupDefaultInfo() {
        
        if let birthday = _AppCoreData.userDataSource.value?.birthday {
            birthdayTxtField.text = birthday.toDateString()
        }
    
        if let phone = _AppCoreData.userDataSource.value?.phone, phone != "" {
            phoneTxtField.text = phone
        }
        if let email = _AppCoreData.userDataSource.value?.email, email != "" {
            emailTxtField.text = email
        }
        
    }
    
    
    func setupButtons() {
        
        setupBackButton()
       
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Personal Information", for: .normal)
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
