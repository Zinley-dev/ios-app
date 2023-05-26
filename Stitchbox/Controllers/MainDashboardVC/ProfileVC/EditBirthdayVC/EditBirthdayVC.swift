//
//  EditBirthdayVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/10/23.
//

import UIKit

class EditBirthdayVC: UIViewController, UITextFieldDelegate {

    let backButton: UIButton = UIButton(type: .custom)
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var birthdayTxtField: UITextField! {
        didSet {
            let redPlaceholderText = NSAttributedString(string: "Your birthday",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            birthdayTxtField.attributedPlaceholder = redPlaceholderText
        }
    }
    
    
    var datePicker = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
        birthdayTxtField.delegate = self
        birthdayTxtField.addTarget(self, action: #selector(EditBirthdayVC.textFieldDidChange(_:)), for: .editingChanged)
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        delay(0.1) {
            self.birthdayTxtField.addUnderLine()
        }
      
    }
    
    @IBAction func birthdayBtnPressed(_ sender: Any) {
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -8, to: Date())
        birthdayTxtField.inputView = datePicker
        datePicker.addTarget(self, action: #selector(EditBirthdayVC.datePickerValueChanged), for: UIControl.Event.valueChanged)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        
        if let birthday = birthdayTxtField.text, birthday != "" {
    
            self.view.endEditing(true)
            presentSwiftLoader()
            APIManager.shared.updateme(params: ["birthday": birthday]) { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "success" else {
                            return
                    }
                    
                    
                    DispatchQueue.main {
                        
                        SwiftLoader.hide()
                        showNote(text: "Updated successfully")
                
                        self.birthdayTxtField.placeholder = birthday
                        self.birthdayTxtField.text = ""
                        reloadGlobalUserInformation()
                        
                    }
                    
                case .failure(let error):
                    SwiftLoader.hide()
                    
                    DispatchQueue.main {
                        self.showErrorAlert("Oops!", msg: error.localizedDescription)
                    }
                  
                }
            }
            
        } else {
            showErrorAlert("Oops!", msg: "Please input your birthday")
        }
        
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
}

extension EditBirthdayVC {
    
    
    func setupDefaultInfo() {
        if let birthday = _AppCoreData.userDataSource.value?.birthday {
            birthdayTxtField.placeholder = birthday.toDateString()
        } else {
            birthdayTxtField.placeholder = "MM/DD/YYYY"
        }
        
    }
    
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
        navigationItem.title = "Edit Birthday"

        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

}


extension EditBirthdayVC {
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US")
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        dateFormatter.dateFormat = "MM-dd-yyyy"
        birthdayTxtField.text = dateFormatter.string(from: sender.date)

    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        if let text = birthdayTxtField.text, text != "" {
            
            saveBtn.backgroundColor = .primary
            saveBtn.titleLabel?.textColor = .white
            
        } else {
            
            
            saveBtn.backgroundColor = .disableButtonBackground
            saveBtn.titleLabel?.textColor = .lightGray
            
        }
        
    }
    
}

