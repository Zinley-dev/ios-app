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
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        
        present(alert, animated: true, completion: nil)
        
    }
    
    // MARK: - Functions
    func bindUI(with: ViewModelType) {
        // bind View Model outputs to Controller elements
        viewModel.output.errorsObservable
            .subscribe(onNext: { (error) in
                
                Dispatch.main.async { [weak self] in
                    guard let self = self else { return }
                    SwiftLoader.hide()
                    self.showErrorAlert("Oops!", msg: error.localizedDescription)
                }
               
                
            })
            .disposed(by: disposeBag)
        
        viewModel.output.loginResultObservable
            .subscribe(onNext: { result in
              switch result {
                case .normal:
                  SwiftLoader.hide()
                  RedirectionHelper.redirectToDashboard()
                  
                case .advance(let type, let value):
                  Dispatch.main.async { [weak self] in
                      guard let self = self else { return }
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
        let userInputs = Observable.combineLatest(
            usernameTextfield.rx.text.orEmpty,
            passwordTextfield.rx.text.orEmpty) { ($0, $1) }

        signInButton.rx.tap.asObservable()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // Avoid multiple taps
            .do(onNext: { _ in // Added this block
                DispatchQueue.main.async {
                    presentSwiftLoader()
                }
            })
            .withLatestFrom(userInputs)
            .subscribe(onNext: { username, password in
          
                if username.isEmpty {
                    // Handle empty username here
                    print("Username is empty")
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        // Show error message if necessary
                    }
                } else if password.isEmpty {
                    // Handle empty password here
                    print("Password is empty")
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        // Show error message if necessary
                    }
                } else {
                    viewModel.action.signInDidTap.onNext((username, password))
                }
            })
            .disposed(by: disposeBag)
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
