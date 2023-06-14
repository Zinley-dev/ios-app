import UIKit
import RxSwift
import RxCocoa

class LoginController: UIViewController, ControllerType {
    typealias ViewModelType = LoginControllerViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    @IBOutlet weak var forgotBtn: UIButton!
  
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        forgotBtn.addTarget(self, action: #selector(onClickForgot(_:)), for: .touchUpInside)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        passwordTextfield.addUnderLine()
        usernameTextfield.addUnderLine()
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    // MARK: - Functions
    func bindUI(with: ViewModelType) {
        // bind View Model outputs to Controller elements
        viewModel.output.errorsObservable
            .subscribe(onNext: { (error) in
                
                DispatchQueue.main.async {
                    
                   presentSwiftLoader()
                    
                }
                
                
            })
            .disposed(by: disposeBag)
        
        viewModel.output.loginResultObservable
            .subscribe(onNext: { result in
              switch result {
                case .normal:
                  RedirectionHelper.redirectToDashboard()
                case .advance(let type, let value):
                  Dispatch.main.async {
                    let model = LoginByPhoneVerifyViewModel()
                    model.output.type = type ?? ""
                    model.output.phoneNumber = value ?? ""
                    model.input.phoneObserver.onNext(value ?? "")
                    model.input.countryCodeObserver.onNext("")
                    SwiftLoader.hide()
                    self.navigationController?.pushViewController(LoginByPhoneVerifyController.create(with: model), animated: true)
                  }
              }
            })
            .disposed(by: disposeBag)
        
    }
    
    func bindAction(with viewModel: LoginControllerViewModel) {
        // binding Controller actions to View Model observer
        let userInputs = Observable.combineLatest(
            usernameTextfield.rx.text.orEmpty,
            passwordTextfield.rx.text.orEmpty) { ($0, $1) 
            }
        signInButton.rx.tap.asObservable()
            .withLatestFrom(userInputs)
            .subscribe(viewModel.action.signInDidTap)
            .disposed(by: disposeBag)
        
        signInButton.rx.tap.asObservable().subscribe { Void in
          Dispatch.main.async {
            presentSwiftLoader()
          }
        }.disposed(by: disposeBag)
    }
  
    @objc func onClickForgot(_ sender: AnyObject) {
      if let navigationController = self.navigationController {
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ResetPasswordVC") as? ResetPasswordVC {
          navigationController.pushViewController(controller, animated: true)
        }
      }
    }
    
}

extension LoginController {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "LoginController", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        controller.viewModel = viewModel
        return controller
    }
}
