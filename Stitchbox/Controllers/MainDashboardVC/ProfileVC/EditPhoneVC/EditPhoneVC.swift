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
        
        
    }
    
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
    
}
