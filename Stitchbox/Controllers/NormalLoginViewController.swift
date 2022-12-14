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
        bindAction(with: viewModel)
    }
    
    // MARK: - Functions
    func bindUI(with: ViewModelType) {
        // bind View Model outputs to Controller elements
        viewModel.output.errorsObservable
            .subscribe(onNext: { (error) in
                DispatchQueue.main.async {
                    self.presentError(error: error)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.loginResultObservable
            .subscribe(onNext: { isTrue in
                if(isTrue){
                    RedirectionHelper.redirectToDashboard()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    func bindAction(with viewModel: LoginControllerViewModel) {
        // binding Controller actions to View Model observer
        let userInputs = Observable.combineLatest(
            usernameTextfield.rx.text.orEmpty,
            passwordTextfield.rx.text.orEmpty) { (email, password) -> (String, String) in
            return (email, password)
        }
        signInButton.rx.tap.asObservable()
            .withLatestFrom(userInputs)
            .subscribe(viewModel.action.signInDidTap)
            .disposed(by: disposeBag)
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
