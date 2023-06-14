//
//  EditSloganVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/20/23.
//

import UIKit

class EditSloganVC: UIViewController, UITextFieldDelegate {

    let backButton: UIButton = UIButton(type: .custom)
    @IBOutlet weak var saveBtn: UIButton!
    
    @IBOutlet weak var sloganTextField: UITextField! {
        didSet {
            let redPlaceholderText = NSAttributedString(string: _AppCoreData.userDataSource.value?.challengeCard?.quote ?? "Best adc NA?",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            sloganTextField.attributedPlaceholder = redPlaceholderText
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        sloganTextField.delegate = self
        sloganTextField.addTarget(self, action: #selector(EditSloganVC.textFieldDidChange(_:)), for: .editingChanged)
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        delay(0.1) {
            self.sloganTextField.addUnderLine()
        }
      
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        if let text = sloganTextField.text, text != "" {
            
            presentSwiftLoader()
            APIManager.shared.updateChallengeCard(params: ["quote": text]) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "success" else {
                            return
                    }
                    
                    DispatchQueue.main {
                        SwiftLoader.hide()
                        newSlogan = text
                        self.sloganTextField.text = ""
                        self.sloganTextField.placeholder = text
                        self.saveBtn.backgroundColor = .disableButtonBackground
                        self.saveBtn.titleLabel?.textColor = .lightGray
                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshData")), object: nil)
                        showNote(text: "Updated successfully")
                    }
                    
                case .failure(let error):
                    DispatchQueue.main {
                        print(error)
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: error.localizedDescription)
                    }
                
                }
            }
            
            
        } else {
            
            self.showErrorAlert("Oops!", msg: "Please enter your slogan for challenge card")
            
        }
        
    }

}

extension EditSloganVC {
    
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
        navigationItem.title = "Edit Slogan"
       
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }
    
   
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}

extension EditSloganVC {
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        if let text = sloganTextField.text, text != "" {
            
            
            self.saveBtn.backgroundColor = .primary
            self.saveBtn.titleLabel?.textColor = .white
            
            
        } else {
            
            self.saveBtn.backgroundColor = .disableButtonBackground
            self.saveBtn.titleLabel?.textColor = .lightGray
            
        }
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
}
