//
//  VerifyCodeVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/10/23.
//

import UIKit

class VerifyCodeVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var openKeyBoardBtn: UIButton!
   
    
    var border1 = CALayer()
    var border2 = CALayer()
    var border3 = CALayer()
    var border4 = CALayer()
    var border5 = CALayer()
    var border6 = CALayer()
    
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    
    
    
    var selectedColor = UIColor.secondary
    var emptyColor = UIColor.white
    
    
    let backButton: UIButton = UIButton(type: .custom)
    @IBOutlet weak var HidenTxtView: UITextField!

    
    @IBOutlet weak var sentAddressLbl: UILabel!
    var type = ""
    var phone = ""
    var email = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        if type == "phone" {
            sentAddressLbl.text = phone
        } else if type == "email" {
            sentAddressLbl.text = email
            
        } else {
            sentAddressLbl.text = "\(type) method"
        }
        
        
        setupEmptyField()
        
    }
    
    @objc func openKeyBoardBtnPressed() {
        
        self.HidenTxtView.becomeFirstResponder()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    
        
        self.view.endEditing(true)
        
    }
    
    func setupEmptyField() {
        
        openKeyBoardBtn.setTitle("", for: .normal)
        
        border1 = label1.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        border2 = label2.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        border3 = label3.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        border4 = label4.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        border5 = label5.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        border6 = label6.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        
        setupView()
        
        HidenTxtView.delegate = self
        HidenTxtView.keyboardType = .numberPad
        HidenTxtView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        HidenTxtView.becomeFirstResponder()
        
        
        openKeyBoardBtn.addTarget(self, action: #selector(LoginByPhoneVerifyController.openKeyBoardBtnPressed), for: .touchUpInside)
    }
    
    
    func setupView() {
        
        label1.layer.addSublayer(border1)
        label2.layer.addSublayer(border2)
        label3.layer.addSublayer(border3)
        label4.layer.addSublayer(border4)
        label5.layer.addSublayer(border5)
        label6.layer.addSublayer(border6)
        
    }
    
    func getTextInPosition(text: String, position: Int) -> String {
        guard position < text.count else { return "Fail" }
        return String(text[text.index(text.startIndex, offsetBy: position)])
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if HidenTxtView.text?.count == 1 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = emptyColor.cgColor
            border3.backgroundColor = emptyColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
            label1.text = getTextInPosition(text: HidenTxtView.text!, position: 0)
            label2.text = ""
            label3.text = ""
            label4.text = ""
            label5.text = ""
            label6.text = ""
            
        } else if HidenTxtView.text?.count == 2 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = emptyColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            label2.text = getTextInPosition(text: HidenTxtView.text!, position: 1)
            label3.text = ""
            label4.text = ""
            label5.text = ""
            label6.text = ""
            
        } else if HidenTxtView.text?.count == 3 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            label3.text = getTextInPosition(text: HidenTxtView.text!, position: 2)
            label4.text = ""
            label5.text = ""
            label6.text = ""
            
        } else if HidenTxtView.text?.count == 4 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = selectedColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            
            label4.text = getTextInPosition(text: HidenTxtView.text!, position: 3)
            label5.text = ""
            label6.text = ""
            
            
        } else if HidenTxtView.text?.count == 5 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = selectedColor.cgColor
            border5.backgroundColor = selectedColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            label5.text = getTextInPosition(text: HidenTxtView.text!, position: 4)
            label6.text = ""
            
        } else if HidenTxtView.text?.count == 6 {
            
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = selectedColor.cgColor
            border5.backgroundColor = selectedColor.cgColor
            border6.backgroundColor = selectedColor.cgColor
            
           
            label6.text = getTextInPosition(text: HidenTxtView.text!, position: 5)
            
            if let code = HidenTxtView.text, code.count == 6 {
                saveProcess()
            } else {
                
                border1.backgroundColor = emptyColor.cgColor
                border2.backgroundColor = emptyColor.cgColor
                border3.backgroundColor = emptyColor.cgColor
                border4.backgroundColor = emptyColor.cgColor
                border5.backgroundColor = emptyColor.cgColor
                border6.backgroundColor = emptyColor.cgColor
                
                label1.text = ""
                label2.text = ""
                label3.text = ""
                label4.text = ""
                label5.text = ""
                label6.text = ""
                
                HidenTxtView.text = ""
                
                self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your phone again.")
                
                
            }
            
            
        } else if HidenTxtView.text?.count == 0 {
            
            
            border1.backgroundColor = emptyColor.cgColor
            border2.backgroundColor = emptyColor.cgColor
            border3.backgroundColor = emptyColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
            label1.text = ""
            label2.text = ""
            label3.text = ""
            label4.text = ""
            label5.text = ""
            label6.text = ""
            
        }
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        saveProcess()

    }
    
    @IBAction func resendBtnPressed(_ sender: Any) {
        
        if type == "phone" {
            resendCodeForPhone()
        } else if type == "email" {
            resendCodeForEmail()
            
        } else {
            
            if type == "2FA - phone" {
                resendCodeFor2FAPhone()
            } else if type == "2FA - email" {
                resendCodeFor2FAEmail()
            }
            
        }
        
    }
    
    
    func saveProcess() {
        
        if let code = HidenTxtView.text, code.count == 6 {
            
            if type == "phone" {
                verifyPhone(code: code)
            } else if type == "email" {
                verifyEmail(code: code)
            } else {
                verify2FA(code: code)
            }
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Please try to input your code again")
            
        }
        
    }
    
}

extension VerifyCodeVC {
    
    func verifyEmail(code: String) {
        
        presentSwiftLoader()
        
        APIManager().verifyUpdateEmail(params: ["device": UIDevice.current.name, "os": UIDevice.current.systemVersion, "email": email, "otp": code]) { result in
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "Email Updated successfully" else {
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "This phone may not be updated successfully, please try again")
                        
                        self.border1.backgroundColor = self.emptyColor.cgColor
                        self.border2.backgroundColor = self.emptyColor.cgColor
                        self.border3.backgroundColor = self.emptyColor.cgColor
                        self.border4.backgroundColor = self.emptyColor.cgColor
                        self.border5.backgroundColor = self.emptyColor.cgColor
                        self.border6.backgroundColor = self.emptyColor.cgColor
                        
                        self.label1.text = ""
                        self.label2.text = ""
                        self.label3.text = ""
                        self.label4.text = ""
                        self.label5.text = ""
                        self.label6.text = ""
                        
                        self.HidenTxtView.text = ""
                        reloadGlobalUserInformation()
                    }
                    
                    
                    return
                }
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    showNote(text: "Email is updated successfully")
                    self.navigationController?.popBack(2)
                }
                
                
            case .failure(let error):
                
                print(error)
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: "Unable to verify your code, please try again")
                    
                    self.border1.backgroundColor = self.emptyColor.cgColor
                    self.border2.backgroundColor = self.emptyColor.cgColor
                    self.border3.backgroundColor = self.emptyColor.cgColor
                    self.border4.backgroundColor = self.emptyColor.cgColor
                    self.border5.backgroundColor = self.emptyColor.cgColor
                    self.border6.backgroundColor = self.emptyColor.cgColor
                    
                    self.label1.text = ""
                    self.label2.text = ""
                    self.label3.text = ""
                    self.label4.text = ""
                    self.label5.text = ""
                    self.label6.text = ""
                    
                    self.HidenTxtView.text = ""
                    
                }
               
            }
        }
        
    }
    
    func verifyPhone(code: String) {
        
        presentSwiftLoader()
        
        APIManager().verifyUpdatePhone(params: ["device": UIDevice.current.name, "os": UIDevice.current.systemVersion, "phone": phone, "otp": code]) { result in
            switch result {
            case .success(let apiResponse):
            
                guard apiResponse.body?["message"] as? String == "Phone Updated successfully" else {
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "This phone may not be updated successfully, please try again")
                        
                        self.border1.backgroundColor = self.emptyColor.cgColor
                        self.border2.backgroundColor = self.emptyColor.cgColor
                        self.border3.backgroundColor = self.emptyColor.cgColor
                        self.border4.backgroundColor = self.emptyColor.cgColor
                        self.border5.backgroundColor = self.emptyColor.cgColor
                        self.border6.backgroundColor = self.emptyColor.cgColor
                        
                        self.label1.text = ""
                        self.label2.text = ""
                        self.label3.text = ""
                        self.label4.text = ""
                        self.label5.text = ""
                        self.label6.text = ""
                        
                        self.HidenTxtView.text = ""
                    }
                    
                    
                    return
                }
                
                reloadGlobalUserInformation()
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.navigationController?.popBack(2)
                }
                
                
            case .failure(let error):
                
                print(error)
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: "Unable to verify your code, please try again")
                    
                    self.border1.backgroundColor = self.emptyColor.cgColor
                    self.border2.backgroundColor = self.emptyColor.cgColor
                    self.border3.backgroundColor = self.emptyColor.cgColor
                    self.border4.backgroundColor = self.emptyColor.cgColor
                    self.border5.backgroundColor = self.emptyColor.cgColor
                    self.border6.backgroundColor = self.emptyColor.cgColor
                    
                    self.label1.text = ""
                    self.label2.text = ""
                    self.label3.text = ""
                    self.label4.text = ""
                    self.label5.text = ""
                    self.label6.text = ""
                    
                    self.HidenTxtView.text = ""
                }
               
            }
        }
        
    }
    
    func verify2FA(code: String) {
        
        var typeMethod = ""
        
        if type == "2FA - phone" {
            typeMethod = "phone"
        } else if type == "2FA - email" {
            typeMethod = "email"
        }
        
        
        APIManager().verify2fa(otp: code, method: typeMethod) { result in
            switch result {
            case .success(_):
           
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.navigationController?.popBack(3)
                    reloadGlobalSettings()
                    if self.type == "2FA - phone" {
                        turnOn2FAForPhone()
                    } else if self.type == "2FA - email" {
                        turnOn2FAForEmail()
                    }
                    
                }
                
                
            case .failure(let error):
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: "Unable to verify your code, please try again \(error.localizedDescription)")
                    
                    self.border1.backgroundColor = self.emptyColor.cgColor
                    self.border2.backgroundColor = self.emptyColor.cgColor
                    self.border3.backgroundColor = self.emptyColor.cgColor
                    self.border4.backgroundColor = self.emptyColor.cgColor
                    self.border5.backgroundColor = self.emptyColor.cgColor
                    self.border6.backgroundColor = self.emptyColor.cgColor
                    
                    self.label1.text = ""
                    self.label2.text = ""
                    self.label3.text = ""
                    self.label4.text = ""
                    self.label5.text = ""
                    self.label6.text = ""
                    
                    self.HidenTxtView.text = ""
                }
               
            }
        }
        
    }
    
    func resendCodeForEmail() {
        
        presentSwiftLoader()
        APIManager().updateEmail(email: email) { result in
            switch result {
            case .success(let apiResponse):
                
            
                guard apiResponse.body?["message"] as? String == "OTP sent" else {
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Unable to retrieve if OTP is sent, please try again")
                    }
                
                    return
                }
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    showNote(text: "A new code has been sent to \(self.email)")
                }
              
            case .failure(let error):
            
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    print(error)
                    self.showErrorAlert("Oops!", msg: "This email may already exists or max send attempts reached, please try again")
                }
                
            }
        }
        
    }
    
    func resendCodeForPhone() {
        
        presentSwiftLoader()
        APIManager().updatePhone(phone: phone) { result in
            switch result {
            case .success(let apiResponse):
                
            
                guard apiResponse.body?["message"] as? String == "OTP sent" else {
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Unable to retrieve if OTP is sent, please try again")
                    }
                
                    return
                }
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    showNote(text: "A new code has been sent to \(self.phone)")
                }
              
            case .failure(let error):
            
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    print(error)
                    self.showErrorAlert("Oops!", msg: "This phone number may already exists or max send attempts reached, please try again")
                }
                
            }
        }
        
    }
    
    func resendCodeFor2FAEmail() {
        
        APIManager().turnOn2fa(method: "email") { result in
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "OTP sent" else {
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Cannot request for 2fa verification this time, please try again")
                        
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    showNote(text: "A new code has been sent to \(self.type) method")
                    SwiftLoader.hide()
                }

            case .failure(let error):

                DispatchQueue.main.async {
                    self.showErrorAlert("Oops!", msg: "Cannot turn on your 2fa and this time, please try again")
                }
              
                print(error)
            }
        }
        
    }
    
    func resendCodeFor2FAPhone() {
        
        APIManager().turnOn2fa(method: "phone") { result in
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "OTP sent" else {
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Cannot request for 2fa verification this time, please try again")
                        
                    }
                    
                    return
                }
                
                DispatchQueue.main.async {
                    showNote(text: "A new code has been sent to \(self.type) method")
                    SwiftLoader.hide()
                }

            case .failure(let error):

                DispatchQueue.main.async {
                    self.showErrorAlert("Oops!", msg: "Cannot turn on your 2fa and this time, please try again")
                }
              
                print(error)
            }
        }
        
    }
    
}

extension VerifyCodeVC {
    
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Verify Code", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
}

extension VerifyCodeVC {
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
            
            if self.type == "2FA - phone" {
                turnOff2FAForPhone()
            } else if self.type == "2FA - email" {
                turnOff2FAForEmail()
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
