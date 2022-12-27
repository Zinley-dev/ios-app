
import UIKit
import RxSwift
import RxCocoa
import CountryPickerView

class LoginByPhoneSendCodeController: UIViewController, ControllerType, CountryPickerViewDelegate {
    
    typealias ViewModelType = LoginByPhoneSendCodeViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    private var cpv: CountryPickerView! = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 10))
    private var codeSubject = PublishSubject<Country>()
    
    // MARK: - UI
    @IBOutlet weak var countryCodeNameTextfield: UITextField!
    @IBOutlet weak var countryCodeTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
   
    // function for changing delegate
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        countryCodeTextfield.text = cpv.selectedCountry.phoneCode
    }
    
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup country code field
        cpv.hostViewController = self
        cpv.showCountryNameInView = true
        cpv.showPhoneCodeInView = false
        cpv.textColor = .text
        countryCodeNameTextfield.leftView = cpv
        countryCodeNameTextfield.leftViewMode = .always
        cpv.delegate = self
        countryCodeTextfield.text = cpv.selectedCountry.phoneCode
        bindUI(with: viewModel)
        bindAction(with: viewModel)
    }
    // MARK: - Functions
    func bindUI(with viewModel: LoginByPhoneSendCodeViewModel) {
        // bind View Model outputs to Controller elements
        viewModel.output.errorsObservable
            .subscribe(onNext: { (error) in
                DispatchQueue.main.async {
                    self.presentError(error: error)
              }
            })
            .disposed(by: disposeBag)

        viewModel.output.OTPSentObservable
            .subscribe(onNext: { isTrue in
                if isTrue {
                    
                    DispatchQueue.main.async { [self] in
                        
                        let viewModel = LoginByPhoneVerifyViewModel()
                        phoneTextfield.rx.text.orEmpty.asObservable().subscribe(viewModel.input.phoneObserver)
                            .disposed(by: self.disposeBag)
                        countryCodeTextfield.rx.text.orEmpty.asObservable()
                            .subscribe(viewModel.input.countryCodeObserver)
                            .disposed(by: self.disposeBag)
              
                        self.navigationController?.pushViewController(LoginByPhoneVerifyController.create(with: viewModel), animated: true)
                    }}
              
            })
            .disposed(by: disposeBag)

    }
    func bindAction(with viewModel: LoginByPhoneSendCodeViewModel) {
        sendCodeButton.rx.tap.asObservable()
            .withLatestFrom(phoneTextfield.rx.text.orEmpty.asObservable()) {
                return ($1, self.cpv.selectedCountry.phoneCode) }
            .subscribe(viewModel.action.sendOTPDidTap)
            .disposed(by: disposeBag)
        
        sendCodeButton.rx.tap.asObservable().subscribe { Void in
            self.presentLoading()
        }.disposed(by: disposeBag)
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

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct LoginByPhoneViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PHONE")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController;
    
}

@available(iOS 13, *)
struct LoginByPhonSwitchingView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            TabBarViewControllerRepresentable()
        }
    }
}
#endif
