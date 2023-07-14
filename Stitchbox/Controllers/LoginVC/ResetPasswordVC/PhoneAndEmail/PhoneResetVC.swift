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

class PhoneResetVC: UIViewController, CountryPickerViewDelegate, CountryPickerViewDataSource, ControllerType {
    
    typealias ViewModelType = ResetPasswordViewModel
    
    // MARK: - Properties
    private lazy var vm: ViewModelType! = ViewModelType(vc: self)
    private let disposeBag = DisposeBag()
    
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
        bindUI(with: vm)
      bindAction(with: vm)
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
  
  
    func bindAction(with vm: ViewModelType) {
        sendCodeButton.rx.tap.asObservable()
            .debounce(.milliseconds(5000), scheduler: MainScheduler.instance) // Avoid multiple taps
            .withLatestFrom(phoneTextfield.rx.text.orEmpty.asObservable()) {
                return ($1, self.cpv.selectedCountry.phoneCode)
            }
            .subscribe(vm.action.sendOTPDidTap)
            .disposed(by: disposeBag)
    }

  
    func bindUI(with vm: ViewModelType) {
      // bind View Model outputs to Controller elements
      vm.output.errorsObservable
        .subscribe(onNext: { (error) in
          DispatchQueue.main.async {
            self.presentError(error: error)
          }
        })
        .disposed(by: disposeBag)
      
      vm.output.resetResultObservable
        .subscribe(onNext: { isTrue in
          if(isTrue){
            DispatchQueue.main.async {
              if let navigationController = self.navigationController {
                let phoneFull = "\(self.cpv.selectedCountry.phoneCode)\(self.phoneTextfield.text!)"
                let model = LoginByPhoneVerifyViewModel()
                model.output.type = "phone"
                model.output.method = "change-password"
                model.output.phoneNumber = phoneFull
                model.input.phoneObserver.onNext(phoneFull)
                model.input.countryCodeObserver.onNext("")
                navigationController.pushViewController(LoginByPhoneVerifyController.create(with: model), animated: true)
              }
            }
          }
        })
        .disposed(by: disposeBag)
    }

}
