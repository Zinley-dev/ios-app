
import UIKit
import RxSwift
import RxCocoa

class LoginByPhoneSendCodeController: UIViewController, ControllerType {
    
    typealias ViewModelType = LoginByPhoneViewModel
    
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
        bindUI(with: viewModel)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "MoveToVerifySegue"){
            if let destinationVC = segue.destination as? LoginByPhoneVerifyController {
                destinationVC.setViewModel(viewModel: self.viewModel)
            }
        }
    }
    
    // MARK: - Functions
    func bindUI(with viewModel: ViewModelType) {
        
        // binding Controller inputs to View Model observer
        countryCodeTextfield.rx.text.orEmpty.asObservable()
            .subscribe(viewModel.input.countryCode)
            .disposed(by: disposeBag)
        
        phoneTextfield.rx.text.orEmpty.asObservable()
            .subscribe(viewModel.input.phone)
            .disposed(by: disposeBag)

        sendCodeButton.rx.tap.asObservable()
            .subscribe(viewModel.input.sendOTPDidTap)
            .disposed(by: disposeBag)
        
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
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "MoveToVerifySegue", sender: self)
                    }}
            })
            .disposed(by: disposeBag)

    }
    
    func presentError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error._domain, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

extension LoginByPhoneSendCodeController {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "LogInByPhoneVerifyView", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginByPhoneSendCodeController") as! LoginByPhoneSendCodeController
        controller.viewModel = viewModel
        return controller
    }
}
