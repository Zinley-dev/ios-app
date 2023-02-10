//
//  EditGeneralInformationVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/18/23.
//

import UIKit

class EditGeneralInformationVC: UIViewController, UITextFieldDelegate {

    
    @IBOutlet weak var saveBtn: UIButton!
    let backButton: UIButton = UIButton(type: .custom)
    var type = ""
    
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
        infoTxtField.addTarget(self, action: #selector(StreamingLinkVC.textFieldDidChange(_:)), for: .editingChanged)
        
        if type == "Name" {
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
            
            
        } else if type == "Discord Link" {
            
            processDiscord()
            
        } else if type == "Email" {
            
            
        } else if type == "Phone" {
            
            
        } else if type == "Birthday" {
            
            
            
        }
        
        
    }
}

extension EditGeneralInformationVC {
    
    func processDiscord() {
        
        if let urlString = infoTxtField.text {
            
            if let url = URL(string: urlString) {
                
                if let domain = url.host {
                    
                    if discord_verify(host: domain) == true {

                        APIManager().updateme(params: ["discordLink": urlString]) { result in
                            switch result {
                            case .success(let apiResponse):
                                
                                guard apiResponse.body?["message"] as? String == "success" else {
                                        return
                                }
                                
                                showNote(text: "Updated successfully")
    
                                self.infoTxtField.placeholder = urlString
                                self.infoTxtField.text = ""
                                
                            case .failure(let error):
                                self.showErrorAlert("Oops!", msg: error.localizedDescription)
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
    
            APIManager().updateme(params: ["name": name]) { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "success" else {
                            return
                    }
                    
                    showNote(text: "Updated successfully")
                    
                    self.infoTxtField.placeholder = name
                    self.infoTxtField.text = ""

                case .failure(let error):
                    self.showErrorAlert("Oops!", msg: error.localizedDescription)
                }
            }
            
        }
        
    }
    
    
    func processUsername() {
        
        
        
        
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
            
        } else if type == "Birthday" {
            
            if let birthday = _AppCoreData.userDataSource.value?.birthday, birthday != "" {
                infoTxtField.placeholder = birthday
            } else {
                infoTxtField.placeholder = "MM/DD/YYYY"
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
                
            } else {
                
                saveBtn.backgroundColor = .primary
                saveBtn.titleLabel?.textColor = .white
                
            }
            
            
            
        } else {
            
           
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
    
}
