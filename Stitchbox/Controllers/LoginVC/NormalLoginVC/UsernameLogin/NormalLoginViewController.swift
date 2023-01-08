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
            passwordTextfield.rx.text.orEmpty) { ($0, $1) 
            }
        signInButton.rx.tap.asObservable()
            .withLatestFrom(userInputs)
            .subscribe(viewModel.action.signInDidTap)
            .disposed(by: disposeBag)
        
        signInButton.rx.tap.asObservable().subscribe { Void in
            self.presentLoading()
        }.disposed(by: disposeBag)
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

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct NormalViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "USERNAME")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController;
    
}

@available(iOS 13, *)
struct NormalLoginView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            NormalViewControllerRepresentable()
        }
    }
}
#endif

