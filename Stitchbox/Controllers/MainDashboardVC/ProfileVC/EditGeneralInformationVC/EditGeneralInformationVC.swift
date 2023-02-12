//
//  EditGeneralInformationVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/18/23.
//

import UIKit

class EditGeneralInformationVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var availaleUsernameLbl: UILabel!
    let backButton: UIButton = UIButton(type: .custom)
    var type = ""
    var isUsernameVerify = false
    // to override search task
    lazy var delayItem = workItem()
    
    @IBOutlet weak var infoTxtField: UITextField! {
        didSet {
            let redPlaceholderText = NSAttributedString(string: "Your info?",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            infoTxtField.attributedPlaceholder = redPlaceholderText
        }
    }
    
    @IBOutlet weak var editLblName: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        infoTxtField.delegate = self
        infoTxtField.addTarget(self, action: #selector(EditGeneralInformationVC.textFieldDidChange(_:)), for: .editingChanged)
        
        if type == "Name" || type == "Username" {
            infoTxtField.maxLength = 15
        }

        setupButtons()
        setupLbl()
        loadDefaultInfo()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        delay(0.1) {
            self.infoTxtField.addUnderLine()
        }
      
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        if type == "Name" {
        
            processName()
            
        } else if type == "Username" {
            
            if isUsernameVerify == true {
            
                processUsername()
                
            } else {
                showErrorAlert("Oops!", msg: "Please type your new username and get it verified to be available and try again")
            }
            
        } else if type == "Discord Link" {
        
            processDiscord()
            
        } else if type == "Email" {
            
            
        } else if type == "Phone" {
            
            
        }
        
    }
}

extension EditGeneralInformationVC {
    
    func processDiscord() {
        
        if let urlString = infoTxtField.text {
            
            if let url = URL(string: urlString) {
                
                if let domain = url.host {
                    
                    if discord_verify(host: domain) == true {

                        self.view.endEditing(true)
                        presentSwiftLoader()
                        APIManager().updateme(params: ["discordLink": urlString]) { result in
                            switch result {
                            case .success(let apiResponse):
                                
                                guard apiResponse.body?["message"] as? String == "success" else {
                                        return
                                }
                                
                                DispatchQueue.main {
                                    SwiftLoader.hide()
                                    self.infoTxtField.text = ""
                                    self.infoTxtField.placeholder = urlString
                                    showNote(text: "Updated successfully")
                                }
                                
                            case .failure(let error):
                                DispatchQueue.main {
                                    SwiftLoader.hide()
                                    self.showErrorAlert("Oops!", msg: error.localizedDescription)
                                }
                            
                            }
                        }
                        
                    } else {
                        
                        
                        self.infoTxtField.text = ""
                        self.showErrorAlert("Oops!", msg: "Your current discord link isn't valid/supported now, please check and correct it.")
                        return
                        
                    }
                    
                }
            }
            
        }
        
        
    }
    
    
    func processName() {
        
        if let name = infoTxtField.text, name != "" {
    
            self.view.endEditing(true)
            presentSwiftLoader()
            APIManager().updateme(params: ["name": name]) { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "success" else {
                            return
                    }
                    
                    
                    DispatchQueue.main {
                        
                        SwiftLoader.hide()
                        showNote(text: "Updated successfully")
                
                        self.infoTxtField.placeholder = name
                        self.infoTxtField.text = ""
                        
                    }
                    
                case .failure(let error):
                    DispatchQueue.main {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: error.localizedDescription)
                    }
                }
            }
            
        }
        
    }
    
    
    func processUsername() {
        
        if let username = infoTxtField.text, username != "" {
            
            presentSwiftLoader()
            view.endEditing(true)
            APIManager().checkUsernameExist(username: username) { result in
                switch result {
                case .success(let apiResponse):
                    
                    if let message = apiResponse.body?["message"] as? String  {
                        
                        if message == "username has not been registered" {
                            
                            self.saveUserName(username: username)
                            
                        } else {
                            
                            
                            
                            DispatchQueue.main.async {
                                SwiftLoader.hide()
                                self.showErrorAlert("Oops!", msg: "Your username has been registered")
                                self.isUsernameVerify = false
                                self.availaleUsernameLbl.isHidden = true
                                self.infoTxtField.text = ""
                            }
                            
                        }
                        
                        
                    }
                    
        
                case .failure(let error):
                    
                    DispatchQueue.main.async {
                        self.availaleUsernameLbl.isHidden = true
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: error.localizedDescription)
                    }
                    
                    
                }
            }
            
            
        }
        
        
    }
    
    func saveUserName(username: String) {
        
        APIManager().updateme(params: ["username": username]) { result in
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "success" else {
                        return
                }
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    showNote(text: "Updated successfully")
                    self.infoTxtField.placeholder = username
                    self.infoTxtField.text = ""
                    self.availaleUsernameLbl.isHidden = true
                    self.saveBtn.backgroundColor = .disableButtonBackground
                    self.saveBtn.titleLabel?.textColor = .lightGray
        
                }
            case .failure(let error):
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: error.localizedDescription)
                }
              
            }
        }
        
    }
    
    
}

extension EditGeneralInformationVC {
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Edit \(type)", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    
    func setupLbl() {
        
        editLblName.text = "Your \(type.lowercased())"
        
    }

    
    func loadDefaultInfo() {
        
        if type == "Name" {
            
            if let name = _AppCoreData.userDataSource.value?.name, name != "" {
                infoTxtField.placeholder = name
            } else {
                infoTxtField.placeholder = "Your name"
            }
            
        } else if type == "Username" {
            
            if let username = _AppCoreData.userDataSource.value?.userName, username != "" {
                infoTxtField.placeholder = username
            }
            
        } else if type == "Discord Link" {
            
            if let discord = _AppCoreData.userDataSource.value?.discordUrl, discord != "" {
                infoTxtField.placeholder = discord
            } else {
                infoTxtField.placeholder = "https://discord.gg/TFD4Y8yt"
            }
            
        } else if type == "Email" {
            
            if let email = _AppCoreData.userDataSource.value?.email, email != "" {
                infoTxtField.placeholder = email
            } else {
                infoTxtField.placeholder = "Email"
            }
            
        } else if type == "Phone" {
            
            if let phone = _AppCoreData.userDataSource.value?.phone, phone != "" {
                infoTxtField.placeholder = phone
            } else {
                infoTxtField.placeholder = "+1 ..."
            }
            
        }
    }
    
}

extension EditGeneralInformationVC {
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        if let text = infoTxtField.text, text != "" {
            
            if type == "Discord Link" {
                
                if verifyUrl(urlString: text) == true {
                    
                 
                    saveBtn.backgroundColor = .primary
                    saveBtn.titleLabel?.textColor = .white
                    
                } else {
                    
                  
                    saveBtn.backgroundColor = .disableButtonBackground
                    saveBtn.titleLabel?.textColor = .lightGray
                    
                }
                
            } else if type == "Username" {
                
                
                delayItem.perform(after: 0.25) {
                    if text != "" {
                        self.checkAvailaleName(searchText: text)
                    }
                }
               
                
            } else {
                
                saveBtn.backgroundColor = .primary
                saveBtn.titleLabel?.textColor = .white
                
            }
            
            
            
        } else {
            
            availaleUsernameLbl.isHidden = true
            saveBtn.backgroundColor = .disableButtonBackground
            saveBtn.titleLabel?.textColor = .lightGray
            
        }
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
    func checkAvailaleName(searchText: String) {
        
        APIManager().checkUsernameExist(username: searchText) { result in
            switch result {
            case .success(let apiResponse):
                
                if let message = apiResponse.body?["message"] as? String  {
                    
                    if message == "username has not been registered" {
                        
                        self.isUsernameVerify = true
                        
                        DispatchQueue.main.async {
                            self.availaleUsernameLbl.isHidden = false
                            self.saveBtn.backgroundColor = .primary
                            self.saveBtn.titleLabel?.textColor = .white
                        }
                        
                    } else {
                        
                        self.isUsernameVerify = false
                        
                        DispatchQueue.main.async {
                            self.availaleUsernameLbl.isHidden = true
                            self.saveBtn.backgroundColor = .disableButtonBackground
                            self.saveBtn.titleLabel?.textColor = .lightGray
                        }
                        
                    }
                    
                    
                }
                
    
            case .failure(let error):
                
                DispatchQueue.main.async {
                    self.availaleUsernameLbl.isHidden = true
                    self.saveBtn.backgroundColor = .disableButtonBackground
                    self.saveBtn.titleLabel?.textColor = .lightGray
                }
                
                
                print(error)
            }
        }
        
        
    }
    
}
