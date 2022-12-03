
import UIKit
import RxSwift
import RxCocoa
import CountryPickerView

class LoginByPhoneSendCodeController: UIViewController, ControllerType {
    
    typealias ViewModelType = LoginByPhoneSendCodeViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
    @IBOutlet weak var countryCodeTextfield: UITextField!
    @IBOutlet weak var phoneTextfield: UITextField!
    @IBOutlet weak var sendCodeButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        let cpv = CountryPickerView(frame: CGRect(x: 0, y: 0, width: 120, height: 20))
        countryCodeTextfield.leftView = cpv
        countryCodeTextfield.leftViewMode = .always
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
                        
//                        self.navigationController?.pushViewController(LoginByPhoneVerifyController.create(with: viewModel), animated: true)
                    }}
            })
            .disposed(by: disposeBag)

    }
    func bindAction(with viewModel: LoginByPhoneSendCodeViewModel) {
        sendCodeButton.rx.tap.asObservable()
            .withLatestFrom(phoneTextfield.rx.text.orEmpty.asObservable())
            .withLatestFrom(countryCodeTextfield.rx.text.orEmpty.asObservable()) { ($0, $1) }
            .subscribe(viewModel.action.sendOTPDidTap)
            .disposed(by: disposeBag)
    }
}

extension LoginByPhoneSendCodeController {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "NormalLogin", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginByPhoneSendCodeController") as! LoginByPhoneSendCodeController
        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
