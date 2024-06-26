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
            
        } else if type == "Personal Link" {
            
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
                    
                    self.view.endEditing(true)
                    presentSwiftLoader()
                    APIManager.shared.updateme(params: ["discordLink": urlString]) { [weak self] result in
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let apiResponse):
                            
                            guard apiResponse.body?["message"] as? String == "success" else {
                                return
                            }
                            
                            DispatchQueue.main {
                                SwiftLoader.hide()
                                self.infoTxtField.text = ""
                                self.infoTxtField.placeholder = urlString
                                NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshData")), object: nil)
                                showNote(text: "Updated successfully")
                                
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
            
        }
        
        
    }
    
    
    func processName() {
        
        if let name = infoTxtField.text, name != "" {
            
            self.view.endEditing(true)
            presentSwiftLoader()
            APIManager.shared.updateme(params: ["name": name]) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "success" else {
                        return
                    }
                    
                    
                    DispatchQueue.main {
                        
                        SwiftLoader.hide()
                        showNote(text: "Updated successfully")
                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshData")), object: nil)
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
            APIManager.shared.checkUsernameExist(username: username) { [weak self] result in
                guard let self = self else { return }
                
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
        
        APIManager.shared.updateme(params: ["username": username]) { [weak self] result in
            guard let self = self else { return }
            
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
                    NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshData")), object: nil)
                    
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
        navigationItem.title = "\(type)"
        
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
            
        } else if type == "Personal Link" {
            
            if let discord = _AppCoreData.userDataSource.value?.discordUrl, discord != "" {
                infoTxtField.placeholder = discord
            } else {
                infoTxtField.placeholder = "https://stitchbox.net/"
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
            
            if type == "Personal Link" {
                
                if verifyUrl(urlString: text) == true {
                    
                    
                    saveBtn.backgroundColor = .secondary
                    saveBtn.titleLabel?.textColor = .white
                    
                } else {
                    
                    
                    saveBtn.backgroundColor = .disableButtonBackground
                    saveBtn.titleLabel?.textColor = .lightGray
                    
                }
                
            } else if type == "Username" {
                
                
                delayItem.perform(after: 0.35) {
                    if text != "", text.count >= 3  {
                        self.checkAvailaleName(searchText: text)
                    }
                }
                
                
            } else {
                
                saveBtn.backgroundColor = .secondary
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
        
        APIManager.shared.checkUsernameExist(username: searchText) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiResponse):
                
                if let message = apiResponse.body?["message"] as? String  {
                    
                    if message == "username has not been registered" {
                        
                        self.isUsernameVerify = true
                        
                        DispatchQueue.main.async {
                            self.availaleUsernameLbl.isHidden = false
                            self.saveBtn.backgroundColor = .secondary
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
