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
  @IBOutlet weak var refCodeTextfield: UnderlineTextField!
  @IBOutlet weak var submitButton: SButton!
  
  @IBOutlet weak var checkUsernameLabel: UILabel!
  @IBOutlet weak var checkPassLengthLabel: UILabel!
  @IBOutlet weak var checkPassNumberLabel: UILabel!
  @IBOutlet weak var checkPassUpperLabel: UILabel!
  @IBOutlet weak var checkPassLowerLabel: UILabel!
  @IBOutlet weak var checkPassSpecialLabel: UILabel!
    
    
    let backButton: UIButton = UIButton(type: .custom)
  
  // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
      super.viewDidLoad()
      submitButton.isEnabled = false
      setupBackButton()
      bindUI(with: viewModel)
      bindAction(with: viewModel)
    }
    
    // MARK: - Functions
    func bindUI(with: ViewModelType) {
      usernameTextfield.rx.text
        .observe(on: MainScheduler.asyncInstance)
        .throttle(.seconds(1), scheduler: MainScheduler.instance)
        .subscribe(onNext: { item in
          self.viewModel.input.usernameSubject.onNext(item ?? "")
        })
//        .map({$0 ?? ""})
//        .bind(to: viewModel.input.usernameSubject)
        .disposed(by: disposeBag)
      passwordTextfield.rx.text.map({$0 ?? ""}).bind(to: viewModel.input.passwordSubject).disposed(by: disposeBag)
       refCodeTextfield.rx.text.map({$0 ?? ""}).bind(to: viewModel.input.refSubject).disposed(by: disposeBag)
        
      viewModel.isValidInput.bind(to: submitButton.rx.isEnabled).disposed(by: disposeBag)
      
      viewModel.isValidUsername.subscribe(onNext: { isValid in
        if !isValid {
          self.checkUsernameLabel.text = "Check availability"
        }
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        usernameTextfield.addUnderLine()
        passwordTextfield.addUnderLine()
        refCodeTextfield.addUnderLine()
    
    }
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    func bindAction(with viewModel: CreateAccountViewModel) {
        
        let userInputs = Observable.combineLatest(
            usernameTextfield.rx.text.orEmpty,
            passwordTextfield.rx.text.orEmpty,
            refCodeTextfield.rx.text.orEmpty) { ($0, $1, $2)
        }
        
      submitButton.rx.tap.asObservable()
        .withLatestFrom(userInputs)
        .subscribe(viewModel.action.submitDidTap)
        .disposed(by: disposeBag)
      
      submitButton.rx.tap.asObservable().subscribe { Void in
          presentSwiftLoader()
      }.disposed(by: disposeBag)
      
      viewModel.output.registerSuccessObservable
        .subscribe(onNext: { [weak self] successMessage in
            DispatchQueue.main.async {
                if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialVC") as? TutorialVC {
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc, animated: true)
                }

            }
            
        })
        .disposed(by: disposeBag)
      
      viewModel.output.errorsObservable
        .subscribe(onNext: { error in
          self.presentError(error: error)
        })
        .disposed(by: disposeBag)
      
      viewModel.output.usernameExistObservable
        .subscribe { exist in
          DispatchQueue.main.async {
            if (exist) {
              self.checkUsernameLabel.text = "Username is available"
              self.checkUsernameLabel.textColor = UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1)
            } else {
              self.checkUsernameLabel.text = "Username is already in use"
              self.checkUsernameLabel.textColor = UIColor.red
              
            }
          }
          
        }.disposed(by: disposeBag)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
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
