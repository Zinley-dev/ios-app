//
//  EditPhoneVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/10/23.
//

import UIKit
import CountryPickerView

class EditPhoneVC: UIViewController, CountryPickerViewDelegate, CountryPickerViewDataSource {
    
    deinit {
        print("EditPhoneVC is being deallocated.")
    }
    
    let backButton: UIButton = UIButton(type: .custom)
    
    private var cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
    // MARK: - UI
    @IBOutlet weak var countryCodeNameTextfield: UITextField!
    @IBOutlet weak var countryCodeTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    
    
    // function for changing delegate
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        countryCodeTextfield.text = cpv.selectedCountry.phoneCode
    }
    
    func countryPickerView(_ countryPickerView: CountryPickerView, willShow viewController: CountryPickerViewController) {
        
        viewController.navigationController?.modalPresentationStyle = .fullScreen
        viewController.navigationController?.navigationBar.tintColor = UIColor.black
        viewController.navigationController?.navigationBar.barTintColor = UIColor.white
        viewController.navigationController?.navigationBar.backgroundColor = UIColor.white
        viewController.navigationController?.navigationBar.bottomBorderColor = UIColor.white
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        cpv.hostViewController = self
        cpv.showCountryNameInView = true
        cpv.showPhoneCodeInView = false
        cpv.textColor = .black
        
        
        countryCodeNameTextfield.leftView = cpv
        countryCodeNameTextfield.leftViewMode = .always
        
        cpv.delegate = self
        cpv.dataSource = self
        
        countryCodeTextfield.text = cpv.selectedCountry.phoneCode
        
        setupButtons()
        setupDefaultInfo()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        countryCodeTextfield.addUnderLine()
        countryCodeNameTextfield.addUnderLine()
        phoneTextfield.addUnderLine()
        
    }
    
    @IBAction func NextBtnPressed(_ sender: Any) {
        
        if let countryCode = countryCodeTextfield.text, countryCode != "", let phone = phoneTextfield.text, phone != "" {
            presentSwiftLoader()
            if(isNotValidInput(Input: phone, RegEx: #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{3,4}$"#)
               || isNotValidInput(Input: countryCode, RegEx: "^(\\+?\\d{1,3}|\\d{1,4})$")) {
                self.showErrorAlert("Oops!", msg: "Phone Number in wrong format")
                return;
            }
            
            self.view.endEditing(true)
            
            APIManager.shared.updatePhone(phone: countryCode + phone) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    
                    print(apiResponse)
                    
                    guard apiResponse.body?["message"] as? String == "OTP sent" else {
                        
                        DispatchQueue.main.async {
                            SwiftLoader.hide()
                            self.showErrorAlert("Oops!", msg: "This phone has been registered")
                            self.phoneTextfield.text = ""
                        }
                        
                        
                        return
                    }
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.moveToVerifyVC(phone: countryCode + phone)
                    }
                    
                case .failure(let error):
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        print(error)
                        self.showErrorAlert("Oops!", msg: "This phone number may already exists or another error occurs, please try again")
                        self.phoneTextfield.text = ""
                    }
                    
                }
            }
            
        } else {
            self.showErrorAlert("Oops!", msg: "Please input your country code and phone in correct format")
        }
        
    }
    
    func moveToVerifyVC(phone: String) {
        
        if let VCVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "VerifyCodeVC") as? VerifyCodeVC {
            
            VCVC.type = "phone"
            VCVC.phone = phone
            self.navigationController?.pushViewController(VCVC, animated: true)
            
        }
        
    }
    
}


extension EditPhoneVC {
    
    
    func setupDefaultInfo() {
        
        if let phone = _AppCoreData.userDataSource.value?.phone, phone != "" {
            phoneTextfield.placeholder = phone.dropFirst().lowercased()
        } else {
            phoneTextfield.placeholder = "Your phone"
        }
        
    }
    
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
        navigationItem.title = "Edit Phone"
        
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
}

extension EditPhoneVC {
    
    
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
