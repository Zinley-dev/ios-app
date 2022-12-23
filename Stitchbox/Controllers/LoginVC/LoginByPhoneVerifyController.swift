//  LoginByPhoneVerifyController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/30/22.
//
import Foundation
import RxSwift

class LoginByPhoneVerifyController: UIViewController, ControllerType {

    typealias ViewModelType = LoginByPhoneVerifyViewModel

    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()

    // MARK: - UI
    @IBOutlet weak var OTPTextfield: OTPStackView!
    @IBOutlet weak var PhoneNumber: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var sendCodeButton: UIButton!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
    }
    // MARK: - Functions
    func bindUI(with viewModel: LoginByPhoneVerifyViewModel) {
        // bind View Model outputs to Controller elements
        viewModel.output.errorsObservable
        .subscribe(onNext: { (error: Error) in
                DispatchQueue.main.async {
                  if (error._code == 900) {
                    self.navigationController?.pushViewController(LastStepViewController.create(), animated: true)
                  } else {
                    self.presentError(error: error)
                  }
                }
            })
            .disposed(by: disposeBag)

        viewModel.output.successObservable
            .subscribe(onNext: { successMessage in
                switch successMessage{
                case .logInSuccess:
                    RedirectionHelper.redirectToDashboard()
                case .sendCodeSuccess:
                    DispatchQueue.main.async {
                        self.presentMessage(message: "New OTP Sent Sucessfully")
                    }
                }
            })
            .disposed(by: disposeBag)
        
        PhoneNumber.text = viewModel.output.phoneNumber

    }
    func bindAction(with viewModel: LoginByPhoneVerifyViewModel) {
        sendCodeButton.rx.tap.asObservable().subscribe(viewModel.action.sendOTPDidTap).disposed(by: disposeBag)
        verifyButton.rx.tap.asObservable().map({ () in
            (self.OTPTextfield.text)
        }).subscribe(viewModel.action.verifyOTPDidTap).disposed(by: disposeBag)
    }
}


extension LoginByPhoneVerifyController {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PHONEVERIFY") as! LoginByPhoneVerifyController
        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}

#if canImport(SwiftUI) && DEBUG
import SwiftUI

struct LoginByPhoneVerifyViewControllerRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PHONEVERIFY")
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = UIViewController;
    
}

@available(iOS 13, *)
struct LoginByPhoneVerifySwitchingView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            LoginByPhoneVerifyViewControllerRepresentable()
        }
    }
}
#endif
