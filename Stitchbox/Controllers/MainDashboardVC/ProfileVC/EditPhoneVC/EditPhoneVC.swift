//
//  EditPhoneVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/10/23.
//

import UIKit
import CountryPickerView

class EditPhoneVC: UIViewController, CountryPickerViewDelegate, CountryPickerViewDataSource {
 

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
        viewController.navigationController?.navigationBar.tintColor = UIColor.white
        viewController.navigationController?.navigationBar.barTintColor = UIColor.background
        viewController.navigationController?.navigationBar.backgroundColor = UIColor.background
        viewController.navigationController?.navigationBar.bottomBorderColor = UIColor.black
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        cpv.hostViewController = self
        cpv.showCountryNameInView = true
        cpv.showPhoneCodeInView = false
        cpv.textColor = .white
        

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
            
            APIManager().checkPhoneExist(phone: countryCode + phone) { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "phone has not been registered" else {
                        
                        DispatchQueue.main.async {
                            SwiftLoader.hide()
                            self.showErrorAlert("Oops!", msg: "This phone has been registered")
                            self.phoneTextfield.text = ""
                        }
                        
                        
                        return
                    }
                    
                    
                    self.processVerify()
                
                case .failure(let error):
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: error.localizedDescription)
                        self.phoneTextfield.text = ""
                    }
                    
                }
            }
            
            
            
        } else {
            self.showErrorAlert("Oops!", msg: "Please input your country code and phone in correct format")
        }
        
    }
    
    
    func processVerify() {
        
        
        if let countryCode = countryCodeTextfield.text, countryCode != "", let phone = phoneTextfield.text, phone != "" {
            
            APIManager().phoneLogin(phone: countryCode + phone) { result in
                switch result {
                case .success(let apiResponse):
                    
                    print(apiResponse)
                    
                    guard apiResponse.body?["message"] as? String == "phone has not been registered" else {
                        
                        /*
                        DispatchQueue.main.async {
                            SwiftLoader.hide()
                            //self.showErrorAlert("Oops!", msg: "Can't request f")
                            self.phoneTextfield.text = ""
                        }
                        */
                        
                        return
                    }
                    
                    
                    
                
                case .failure(let error):
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: error.localizedDescription)
                        self.phoneTextfield.text = ""
                    }
                    
                }
            }
            
            
        } else {
            
            SwiftLoader.hide()
            self.showErrorAlert("Oops!", msg: "Please input your country code and phone in correct format")
            
        }
        
    
    }
    
    /*
     if(isNotValidInput(Input: phone, RegEx: #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{3,4}$"#)
        || isNotValidInput(Input: countryCode, RegEx: "^(\\+?\\d{1,3}|\\d{1,4})$")) {
         self.errorsSubject.onNext(NSError(domain: "Phone Number in wrong format", code: 200))
         return;
     }
     // call api toward login api of backend
     APIManager().phoneLogin(phone: countryCode + phone) { result in switch result {
     case .success(let apiResponse):
         // get and process data
         _ = apiResponse.body?["data"] as! [String: Any]?
         // save datasource
         let initMap = ["phone": "\(countryCode)\(phone)", "signinMethod": "phone"]
         let newUserData = Mapper<UserDataSource>().map(JSON: initMap)
         _AppCoreData.userDataSource.accept(newUserData)
         self.OTPSentSubject.onNext(true)
     case .failure(let error):
         print(error)
         self.errorsSubject.onNext(NSError(domain: "Error in send OTP", code: 300))
     }
     }
     */
    
}


extension EditPhoneVC {
    
    
    func setupDefaultInfo() {
        
        if let phone = _AppCoreData.userDataSource.value?.phone, phone != "" {
            phoneTextfield.placeholder = phone
        } else {
            phoneTextfield.placeholder = "Your phone"
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
        backButton.setTitle("     Edit Phone", for: .normal)
        backButton.sizeToFit()
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
