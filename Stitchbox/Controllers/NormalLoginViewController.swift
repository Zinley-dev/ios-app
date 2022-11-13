
import UIKit
import RxSwift
import RxCocoa

class LoginController: UIViewController, ControllerType {
    typealias ViewModelType = LoginControllerViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType!
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindUI(with: viewModel)
    }
    
    // MARK: - Functions
    func bindUI(with viewModel: ViewModelType) {
        
        emailTextfield.rx.text.orEmpty.asObservable()
            .subscribe(viewModel.input.email)
            .disposed(by: disposeBag)
        
        passwordTextfield.rx.text.orEmpty.asObservable()
            .subscribe(viewModel.input.password)
            .disposed(by: disposeBag)
        
        signInButton.rx.tap.asObservable()
            .subscribe(viewModel.input.signInDidTap)
            .disposed(by: disposeBag)
        
        viewModel.output.errorsObservable
            .subscribe(onNext: { [unowned self] (error) in
                self.presentError(error: error)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.loginResultObservable
            .subscribe(onNext: { [unowned self] (user) in
                self.presentMessage(message: "User successfully signed in")
            })
            .disposed(by: disposeBag)

    }
    
    func presentError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
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
