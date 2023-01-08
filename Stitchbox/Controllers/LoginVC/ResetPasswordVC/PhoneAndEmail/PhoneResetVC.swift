//
//  PhoneResetVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/8/23.
//

import UIKit
import RxSwift
import RxCocoa
import CountryPickerView

class PhoneResetVC: UIViewController, CountryPickerViewDelegate, CountryPickerViewDataSource {
    
    
    private var cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
    private var codeSubject = PublishSubject<Country>()
    
    @IBOutlet weak var countryCodeNameTextfield: UITextField!
    @IBOutlet weak var countryCodeTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    var CountryPickerVC: CountryPickerViewController!
   
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
    
        //setup country code field
        cpv.hostViewController = self
        cpv.showCountryNameInView = true
        cpv.showPhoneCodeInView = false
        cpv.textColor = .white
        

        countryCodeNameTextfield.leftView = cpv
        countryCodeNameTextfield.leftViewMode = .always
       
        cpv.delegate = self
        cpv.dataSource = self
        
        countryCodeTextfield.text = cpv.selectedCountry.phoneCode
      
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        countryCodeTextfield.addUnderLine()
        countryCodeNameTextfield.addUnderLine()
        phoneTextfield.addUnderLine()
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }

}
