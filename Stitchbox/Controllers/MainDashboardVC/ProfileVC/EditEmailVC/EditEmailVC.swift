//
//  EditEmailVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/10/23.
//

import UIKit

class EditEmailVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    @IBOutlet weak var emailTxtField: UITextField!
    
    @IBOutlet weak var nextBtn: SButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupDefaultInfo()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        emailTxtField.addUnderLine()
    }
    

    @IBAction func nextBtnPressed(_ sender: Any) {
        
        if let email = emailTxtField.text, email != "", email.contains("@") == true, email.contains(".") == true {
                
            checkEmail(email: email)
            
        } else {
            
            showErrorAlert("Oops !", msg: "Please enter your valid email.")
            
        }
        
    }
    
    func checkEmail(email: String) {
        
        let lowercaseEmail = email.lowercased().stringByRemovingWhitespaces
        presentSwiftLoader()
   
        APIManager().updateEmail(email: lowercaseEmail) { result in
            switch result {
            case .success(let apiResponse):
                
                guard apiResponse.body?["message"] as? String == "OTP sent" else {
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "This email has been registered")
                        self.emailTxtField.text = ""
                    }
                    
                    
                    return
                }
                
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.moveToVerifyVC(email: lowercaseEmail)
                }
              
            case .failure(let error):
            
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    print(error)
                    self.showErrorAlert("Oops!", msg: "This email may already exists or another error occurs, please try again")
                    self.emailTxtField.text = ""
                }
                
            }
        }
        
    }
    
    func moveToVerifyVC(email: String) {
        
        if let VCVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "VerifyCodeVC") as? VerifyCodeVC {
            
            VCVC.type = "email"
            VCVC.email = email
            self.navigationController?.pushViewController(VCVC, animated: true)
            
        }
        
    }
    

    
}

extension EditEmailVC {
    
    
    func setupDefaultInfo() {
        
        if let email = _AppCoreData.userDataSource.value?.email, email != "" {
            emailTxtField.placeholder = email
        } else {
            emailTxtField.placeholder = "Your email"
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
        backButton.setTitle("     Edit Email", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
}


extension EditEmailVC {
    
    
    
    
}

extension EditEmailVC {
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
}
