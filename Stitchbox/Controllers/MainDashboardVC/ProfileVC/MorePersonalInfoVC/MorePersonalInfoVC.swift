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
    
    
    @IBAction func editEmailPressed(_ sender: Any) {
        
        if let EGIVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditGeneralInformationVC") as? EditGeneralInformationVC {
            
            EGIVC.type = "Email"
            self.navigationController?.pushViewController(EGIVC, animated: true)
            
        }
        
    }
    
    
    @IBAction func editPhonePressed(_ sender: Any) {
        
        if let EGIVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditGeneralInformationVC") as? EditGeneralInformationVC {
            
            EGIVC.type = "Phone"
            self.navigationController?.pushViewController(EGIVC, animated: true)
            
        }
        
        
    }
    
    
    @IBAction func editBirthdayTxtField(_ sender: Any) {
        
        if let EGIVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "EditGeneralInformationVC") as? EditGeneralInformationVC {
            
            EGIVC.type = "Birthday"
            self.navigationController?.pushViewController(EGIVC, animated: true)
            
        }
        
    }
    
    
    
}


extension MorePersonalInfoVC {
    
    func setupButtons() {
        
        setupBackButton()
       
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
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