//
//  EmailResetVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/8/23.
//

import UIKit
import RxSwift
import RxCocoa

class EmailResetVC: UIViewController, ControllerType {
    
  
    typealias ViewModelType = ResetPasswordViewModel
    
    // MARK: - Properties
    private lazy var vm: ViewModelType! = ViewModelType(vc: self)
    private let disposeBag = DisposeBag()
  
  
    @IBOutlet weak var nextBtn: SButton!
    @IBOutlet weak var emailTxtField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        bindUI(with: vm)
        bindAction(with: vm)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        emailTxtField.addUnderLine()
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.view.endEditing(true)
    }
    
    func bindUI(with viewModel: ResetPasswordViewModel) {
      viewModel.output.errorsObservable
        .subscribe(onNext: { (error) in
          DispatchQueue.main.async {
            self.presentError(error: error)
          }
        })
        .disposed(by: disposeBag)
      
      viewModel.output.resetResultObservable
        .subscribe(onNext: { isTrue in
          if(isTrue){
            DispatchQueue.main.async {
              if let navigationController = self.navigationController {
                
                let model = LoginByPhoneVerifyViewModel()
                model.output.type = "email"
                model.output.method = "change-password"
                model.output.phoneNumber = self.emailTxtField.text!
                model.input.phoneObserver.onNext(self.emailTxtField.text ?? "")
                model.input.countryCodeObserver.onNext("")
                navigationController.pushViewController(LoginByPhoneVerifyController.create(with: model), animated: true)
              }
            }
          }
        })
        .disposed(by: disposeBag)
    }
    
    func bindAction(with viewModel: ResetPasswordViewModel) {
      nextBtn.rx.tap.asObservable()
        .withLatestFrom(emailTxtField.rx.text.orEmpty.asObservable()) {
          return $1 }
        .subscribe(vm.action.sendOTPViaEmailDidTap)
        .disposed(by: disposeBag)
    }


}
