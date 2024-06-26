
import UIKit
import RxSwift
import RxCocoa
import CountryPickerView


class LoginByPhoneSendCodeController: UIViewController, ControllerType, CountryPickerViewDelegate, CountryPickerViewDataSource {
    
    typealias ViewModelType = LoginByPhoneSendCodeViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    private var cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 200, height: 40))
    private var codeSubject = PublishSubject<Country>()
    
    // MARK: - UI
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
        viewController.navigationController?.navigationBar.tintColor = UIColor.black
        viewController.navigationController?.navigationBar.barTintColor = UIColor.white
        viewController.navigationController?.navigationBar.backgroundColor = UIColor.white
        viewController.navigationController?.navigationBar.bottomBorderColor = UIColor.white
        viewController.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
    
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //setup country code field
        cpv.hostViewController = self
        cpv.showCountryNameInView = true
        cpv.showPhoneCodeInView = false
        cpv.textColor = .black
        

        countryCodeNameTextfield.leftView = cpv
        countryCodeNameTextfield.leftViewMode = .always
       
        cpv.delegate = self
        cpv.dataSource = self
        
        countryCodeTextfield.text = cpv.selectedCountry.phoneCode
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        countryCodeTextfield.addUnderLine()
        countryCodeNameTextfield.addUnderLine()
        phoneTextfield.addUnderLine()
        
    }
    

    // MARK: - Functions
    func bindUI(with viewModel: LoginByPhoneSendCodeViewModel) {
        // bind View Model outputs to Controller elements
        viewModel.output.errorsObservable
            .subscribe(onNext: { [weak self] (error) in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                    self.presentError(error: error)
              }
            })
            .disposed(by: disposeBag)

        viewModel.output.OTPSentObservable
            .subscribe(onNext: { isTrue in
                if isTrue {
                    
                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }
                        let viewModel = LoginByPhoneVerifyViewModel()
                        phoneTextfield.rx.text.orEmpty.asObservable().subscribe(viewModel.input.phoneObserver)
                            .disposed(by: self.disposeBag)
                        countryCodeTextfield.rx.text.orEmpty.asObservable()
                            .subscribe(viewModel.input.countryCodeObserver)
                            .disposed(by: self.disposeBag)
              
                        SwiftLoader.hide()
                        self.navigationController?.pushViewController(LoginByPhoneVerifyController.create(with: viewModel), animated: true)
                    }}
              
            })
            .disposed(by: disposeBag)

    }
    func bindAction(with viewModel: LoginByPhoneSendCodeViewModel) {
        
        sendCodeButton.rx.tap.asObservable()
            .withLatestFrom(phoneTextfield.rx.text.orEmpty.asObservable()) { [weak self] in
                guard let self = self else { return ("","")}
                return ($1, self.cpv.selectedCountry.phoneCode) }
            .subscribe(viewModel.action.sendOTPDidTap)
            .disposed(by: disposeBag)
        
        sendCodeButton.rx.tap.asObservable().subscribe { Void in
            presentSwiftLoader()
        }.disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
}

extension LoginByPhoneSendCodeController {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PHONE") as! LoginByPhoneSendCodeController
//        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
