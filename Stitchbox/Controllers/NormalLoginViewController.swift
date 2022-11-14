
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
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI(with: viewModel)
    }
    
    @IBAction func onClickLogin() {
        APIManager().normalLogin(username: usernameTextfield.text!, password: passwordTextfield.text!) { result in print (result)
        }
    }
    
    // MARK: - Functions
    func bindUI(with viewModel: ViewModelType) {
        
        // binding Controller inputs to View Model observer
        usernameTextfield.rx.text.orEmpty.asObservable()
            .subscribe(viewModel.input.username)
            .disposed(by: disposeBag)
        
        passwordTextfield.rx.text.orEmpty.asObservable()
            .subscribe(viewModel.input.password)
            .disposed(by: disposeBag)

        signInButton.rx.tap.asObservable()
            .subscribe(viewModel.input.signInDidTap)
            .disposed(by: disposeBag)
        
        // bind View Model outputs to Controller elements
        viewModel.output.errorsObservable
            .subscribe(onNext: { (error) in
                DispatchQueue.main.async {
                    self.presentError(error: error)
              }
            })
            .disposed(by: disposeBag)

        viewModel.output.loginResultObservable
            .subscribe(onNext: { account in
                DispatchQueue.main.async {
                    // Store account to UserDefault as "userAccount"
                    do {
                        // Create JSON Encoder
                        let encoder = JSONEncoder()

                        // Encode Note
                        let data = try encoder.encode(account)

                        // Write/Set Data
                        UserDefaults.standard.set(data, forKey: "userAccount")

                    } catch {
                        print("Unable to Encode Account (\(error))")
                    }
                    
                    // Perform Segue to DashboardStoryboard
                    self.performSegue(withIdentifier: "DashboardSegue", sender:self)
              }
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

extension LoginController {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        controller.viewModel = viewModel
        return controller
    }
}
