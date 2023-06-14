//
//  NewPasswordVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/8/23.
//

import UIKit
import RxSwift

class NewPasswordVC: UIViewController, ControllerType {
  typealias ViewModelType = NewPasswordViewModel
  
  @IBOutlet weak var enteredPasswordTextfield: UITextField!
  @IBOutlet weak var passwordTextfield: UITextField!
  @IBOutlet weak var nextButton: SButton!
  
  @IBOutlet weak var checkPasswordMatchLabel: UILabel!
  @IBOutlet weak var checkPassLengthLabel: UILabel!
  @IBOutlet weak var checkPassNumberLabel: UILabel!
  @IBOutlet weak var checkPassUpperLabel: UILabel!
  @IBOutlet weak var checkPassLowerLabel: UILabel!
  @IBOutlet weak var checkPassSpecialLabel: UILabel!
  
  let backButton: UIButton = UIButton(type: .custom)
  
  private var viewModel: ViewModelType! = ViewModelType()
  private let disposeBag = DisposeBag()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    setupBackButton()
    nextButton.isEnabled = false
    bindUI(with: viewModel)
    bindAction(with: viewModel)
  }
  
  func bindUI(with: NewPasswordViewModel) {
    passwordTextfield.rx.text.map({$0 ?? ""}).bind(to: viewModel.input.passwordObserver).disposed(by: disposeBag)
    enteredPasswordTextfield.rx.text.map({$0 ?? ""}).bind(to: viewModel.input.rePasswordObserver).disposed(by: disposeBag)
    
    
    viewModel.isValidInput.bind(to: nextButton.rx.isEnabled).disposed(by: disposeBag)
    
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
  
    func bindAction(with viewModel: NewPasswordViewModel) {
        
        let userInputs = Observable.combineLatest(
          passwordTextfield.rx.text.orEmpty,
          enteredPasswordTextfield.rx.text.orEmpty) { ($0, $1) }
        
        nextButton.rx.tap.asObservable()
          .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // Avoid multiple taps
          .withLatestFrom(userInputs)
          .subscribe(viewModel.action.submitDidTap)
          .disposed(by: disposeBag)
        
        nextButton.rx.tap.asObservable()
          .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // Avoid multiple taps
          .subscribe { _ in
            presentSwiftLoader()
          }.disposed(by: disposeBag)
        
        viewModel.output.submitResultObservable
          .subscribe(onNext: { successMessage in
            if successMessage == "success" {
              DispatchQueue.main.async {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "FinalResetVC") as? FinalResetVC {
                  SwiftLoader.hide()
                  self.navigationController?.pushViewController(vc, animated: true)
                }
              }
            }
          })
          .disposed(by: disposeBag)
        
        viewModel.output.errorsObservable
          .subscribe(onNext: { error in
            DispatchQueue.main.async {
              SwiftLoader.hide()
              self.presentErrorAlert(message: "Password not match!")
            }
          })
          .disposed(by: disposeBag)
    }

  
  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    
      self.enteredPasswordTextfield.addUnderLine()
      self.passwordTextfield.addUnderLine()
    
    
  }
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back_icn_white") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }
  
  
  @objc func onClickBack(_ sender: AnyObject) {
    if let navigationController = self.navigationController {
      navigationController.popViewController(animated: true)
    }
  }
  
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    self.view.endEditing(true)
    
  }
  
  
}
