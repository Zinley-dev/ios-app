//
//  LastStepViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 23/12/2022.
//

import UIKit
import RxSwift

class LastStepViewController: UIViewController, ControllerType {
    typealias ViewModelType = CreateAccountViewModel
  
    
  @IBOutlet weak var usernameTextfield: UnderlineTextField!
  @IBOutlet weak var passwordTextfield: UnderlineTextField!
  @IBOutlet weak var submitButton: SButton!
  
  @IBOutlet weak var checkUsernameLabel: UILabel!
  @IBOutlet weak var checkPassLengthLabel: UILabel!
  @IBOutlet weak var checkPassNumberLabel: UILabel!
  @IBOutlet weak var checkPassUpperLabel: UILabel!
  @IBOutlet weak var checkPassLowerLabel: UILabel!
  @IBOutlet weak var checkPassSpecialLabel: UILabel!
  
  // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
      super.viewDidLoad()
      submitButton.isEnabled = false
      bindUI(with: viewModel)
      bindAction(with: viewModel)
    }
    
    // MARK: - Functions
    func bindUI(with: ViewModelType) {
      usernameTextfield.rx.text.map({$0 ?? ""}).bind(to: viewModel.input.usernameSubject).disposed(by: disposeBag)
      passwordTextfield.rx.text.map({$0 ?? ""}).bind(to: viewModel.input.passwordSubject).disposed(by: disposeBag)
      viewModel.isValidInput.bind(to: submitButton.rx.isEnabled).disposed(by: disposeBag)
      
      viewModel.isValidUsername.subscribe(onNext: { isValid in
        self.checkUsernameLabel.textColor = isValid ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray
      })
      viewModel.isValidPassword.subscribe(onNext: { isValid in
        self.checkPassLengthLabel.textColor = isValid ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray
      })
      viewModel.isHasUppercase.subscribe(onNext: { isValid in
        self.checkPassUpperLabel.textColor = isValid ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray
      })
      viewModel.isHasLowercase.subscribe(onNext: { isValid in
        self.checkPassLowerLabel.textColor = isValid ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray
      })
      viewModel.isHasNumber.subscribe(onNext: { isValid in
        self.checkPassNumberLabel.textColor = isValid ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray
      })
      viewModel.isHasSpecial.subscribe(onNext: { isValid in
        self.checkPassSpecialLabel.textColor = isValid ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray
      })
    }
    
    func bindAction(with viewModel: CreateAccountViewModel) {
      
      let userInputs = Observable.combineLatest(
        usernameTextfield.rx.text.orEmpty,
        passwordTextfield.rx.text.orEmpty) { ($0, $1)
        }
      submitButton.rx.tap.asObservable()
        .withLatestFrom(userInputs)
        .subscribe(viewModel.action.submitDidTap)
        .disposed(by: disposeBag)
      
      submitButton.rx.tap.asObservable().subscribe { Void in
        self.presentLoading()
      }.disposed(by: disposeBag)
      
      viewModel.output.registerSuccessObservable
        .subscribe(onNext: { successMessage in
          RedirectionHelper.redirectToDashboard()
        })
        .disposed(by: disposeBag)
      
      viewModel.output.errorsObservable
        .subscribe(onNext: { error in
          self.presentError(error: error)
        })
        .disposed(by: disposeBag)
    }
}
extension LastStepViewController {
  static func create() -> UIViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let controller = storyboard.instantiateViewController(withIdentifier: "LastStepViewController") as! LastStepViewController
    controller.modalPresentationStyle = .fullScreen
    return controller
  }
}
