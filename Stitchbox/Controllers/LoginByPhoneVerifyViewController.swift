//
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
    @IBOutlet weak var OTPTextfield: UITextField!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var retypeOTP: UIButton!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
    }
    // MARK: - Functions
    func bindUI(with viewModel: LoginByPhoneVerifyViewModel) {
        OTPTextfield.rx.text.orEmpty.subscribe(viewModel.input.codeObserver).disposed(by: disposeBag)
        // bind View Model outputs to Controller elements
        viewModel.output.errorsObservable
            .subscribe(onNext: { (error) in
                DispatchQueue.main.async {
                    self.presentError(error: error)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.successObservable
            .subscribe(onNext: { successMessage in
                switch successMessage{
                case .logInSuccess:
                    DispatchQueue.main.async {
                        // Perform Segue to DashboardStoryboard
                        self.performSegue(withIdentifier: "DashboardSegue", sender: self)
                    }
                case .sendCodeSuccess:
                    DispatchQueue.main.async {
                        self.presentMessage(message: "New OTP Sent Sucessfully")
                    }
                }
            })
            .disposed(by: disposeBag)
        
    }
    func bindAction(with viewModel: LoginByPhoneVerifyViewModel) {
        sendCodeButton.rx.tap.asObservable().subscribe(viewModel.action.sendOTPDidTap).disposed(by: disposeBag)
        verifyButton.rx.tap.asObservable().subscribe(viewModel.action.verifyOTPDidTap).disposed(by: disposeBag)
        retypeOTP.rx.tap.asObservable().subscribe(onNext: {
            DispatchQueue.main.async { [self] in
                
                let viewModel = LoginByPhoneSendCodeViewModel()
                
                self.navigationController?.pushViewController(LoginByPhoneSendCodeController.create(with: viewModel), animated: true)
            }}).disposed(by: disposeBag)
    }
    
}


extension LoginByPhoneVerifyController {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "NormalLogin", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginByPhoneVerifyController") as! LoginByPhoneVerifyController
        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
