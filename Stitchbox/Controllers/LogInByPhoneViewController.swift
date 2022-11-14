//import UIKit
//import RxSwift
//import RxCocoa
//
////class LoginByPhoneViewController: UIViewController, ControllerType {
//    typealias ViewModelType = LoginByPhoneViewModel
//    
//    // MARK: - Properties
//    private var viewModel: ViewModelType!
//    private let disposeBag = DisposeBag()
//    
//    // MARK: - UI
//    @IBOutlet weak var phoneTextfield: UITextField!
//    @IBOutlet weak var countryCodeTextfield: UITextField!
//    @IBOutlet weak var viaTextfield: UITextField!
//    @IBOutlet weak var getOTPButton: UIButton!
//    
//    // MARK: - Lifecycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        bindUI(with: viewModel)
//    }
//    
//    // MARK: - Functions
//    func bindUI(with viewModel: ViewModelType) {
//        
//        phoneTextfield.rx.text.asObservable()
//            .subscribe(viewModel.input.phone)
//            .disposed(by: disposeBag)
//        
//        countryCodeTextfield.rx.text.asObservable()
//            .subscribe(viewModel.input.countryCode)
//            .disposed(by: disposeBag)
//        
//        viaTextfield.rx.text.asObservable()
//            .subscribe(viewModel.input.via)
//            .disposed(by: disposeBag)
//        
//        getOTPButton.rx.tap.asObservable()
//            .subscribe(viewModel.input.getOTPDidTap)
//            .disposed(by: disposeBag)
//        
//        viewModel.output.errorsObservable
//            .subscribe(onNext: { [unowned self] (error) in
//                self.presentError(error: error)
//            })
//            .disposed(by: disposeBag)
//        
//        viewModel.output.OTPSentObservable
//            .subscribe(onNext: { [unowned self] (user) in
//                self.presentMessage(message: "OTP Sent")
//            })
//            .disposed(by: disposeBag)
//
//    }
//    
//    func presentError(error: Error) {
//        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//    
//    func presentMessage(message: String) {
//        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
//        alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
//}
//
//extension LoginByPhoneViewController {
//    static func create(with viewModel: ViewModelType) -> UIViewController {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let controller = storyboard.instantiateViewController(withIdentifier: "LoginByPhoneViewController") as! LoginByPhoneViewController
//        controller.viewModel = viewModel
//        return controller
//    }
//}
