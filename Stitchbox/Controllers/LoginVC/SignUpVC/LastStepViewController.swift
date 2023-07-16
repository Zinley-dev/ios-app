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
  @IBOutlet weak var submitButton: UIButton!
  
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
    func bindUI(with viewModel: ViewModelType) {
        usernameTextfield.rx.text
            .observe(on: MainScheduler.asyncInstance)
            .throttle(.seconds(1), scheduler: MainScheduler.instance)
            .subscribe(onNext: { item in
              self.viewModel.input.usernameSubject.onNext(item ?? "")
            })
           .disposed(by: disposeBag)

        passwordTextfield.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.input.passwordSubject)
            .disposed(by: disposeBag)

        refCodeTextfield.rx.text
            .map({$0 ?? ""})
            .bind(to: viewModel.input.refSubject)
            .disposed(by: disposeBag)
            
        viewModel.isValidInput.bind(to: submitButton.rx.isEnabled)
            .disposed(by: disposeBag)

        viewModel.isPasswordFilled
            .subscribe(onNext: { isFilled in
                let color: UIColor = isFilled ? UIColor.gray : UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1)
                self.checkPassLengthLabel.textColor = color
                self.checkPassUpperLabel.textColor = color
                self.checkPassLowerLabel.textColor = color
                self.checkPassNumberLabel.textColor = color
                self.checkPassSpecialLabel.textColor = color
            })
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.isPasswordFilled, viewModel.isValidPassword)
            .map { $0 && $1 ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray }
            .bind(to: self.checkPassLengthLabel.rx.textColor)
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.isPasswordFilled, viewModel.isHasUppercase)
            .map { $0 && $1 ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray }
            .bind(to: self.checkPassUpperLabel.rx.textColor)
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.isPasswordFilled, viewModel.isHasLowercase)
            .map { $0 && $1 ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray }
            .bind(to: self.checkPassLowerLabel.rx.textColor)
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.isPasswordFilled, viewModel.isHasNumber)
            .map { $0 && $1 ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray }
            .bind(to: self.checkPassNumberLabel.rx.textColor)
            .disposed(by: disposeBag)

        Observable.combineLatest(viewModel.isPasswordFilled, viewModel.isHasSpecial)
            .map { $0 && $1 ? UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1) : UIColor.gray }
            .bind(to: self.checkPassSpecialLabel.rx.textColor)
            .disposed(by: disposeBag)
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        usernameTextfield.addUnderLine()
        passwordTextfield.addUnderLine()
        refCodeTextfield.addUnderLine()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        usernameTextfield.addUnderLine()
        passwordTextfield.addUnderLine()
        refCodeTextfield.addUnderLine()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        usernameTextfield.addUnderLine()
        passwordTextfield.addUnderLine()
        refCodeTextfield.addUnderLine()
        
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        usernameTextfield.addUnderLine()
        passwordTextfield.addUnderLine()
        refCodeTextfield.addUnderLine()
    
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
    
    func bindAction(with viewModel: CreateAccountViewModel) {
        
        let userInputs = Observable.combineLatest(
            usernameTextfield.rx.text.orEmpty,
            passwordTextfield.rx.text.orEmpty,
            refCodeTextfield.rx.text.orEmpty
        ) { ($0, $1, $2) }
        
        submitButton.rx.tap.asObservable()
            .debounce(.milliseconds(500), scheduler: MainScheduler.instance) // Avoid multiple taps
            .withLatestFrom(userInputs)
            .subscribe(onNext: { [unowned self] username, password, refCode in
                let credentials: (String, String, String)
                
                DispatchQueue.main.async {
                    
                   presentSwiftLoader()
                    
                }
            
                if password.isEmpty {
                    let randomPassword = generateRandomPassword()
                    self.passwordTextfield.text = randomPassword
                    credentials = (username, randomPassword, refCode)
                } else {
                    credentials = (username, password, refCode)
                }
                
                viewModel.action.submitDidTap.onNext(credentials)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.registerSuccessObservable
            .subscribe(onNext: { [weak self] successMessage in
                DispatchQueue.main.async {
                    if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TutorialVC") as? TutorialVC {
                        vc.modalPresentationStyle = .fullScreen
                        SwiftLoader.hide()
                        self?.present(vc, animated: true)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.errorsObservable
            .subscribe(onNext: { error in
                DispatchQueue.main.async {
                    SwiftLoader.hide()
                }
                self.presentError(error: error)
            })
            .disposed(by: disposeBag)
        
        viewModel.output.usernameExistObservable
            .subscribe { exist in
                print("CHECK>.....\(exist)")
                DispatchQueue.main.async {
                    if (exist) {
                        self.checkUsernameLabel.text = "Username is available"
                        self.checkUsernameLabel.textColor = UIColor(red: 92/255.0, green: 195/255.0, blue: 103/255.0, alpha: 1)
                    } else {
                        self.checkUsernameLabel.text = "Username is already in use"
                        self.checkUsernameLabel.textColor = UIColor.red
                    }
                    
                    viewModel.isValidInput.bind(to: self.submitButton.rx.isEnabled)
                        .disposed(by: self.disposeBag)
                }
            }
            .disposed(by: disposeBag)
    }

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func referralBtnPressed(_ sender: Any) {
    
        self.view.endEditing(true)
        getReferralCode()
        
    }
    
    
    func getReferralCode() {
        
        
        if let code = self.refCodeTextfield.text {
            
            showRefInputDialog(subtitle: "You can modify referral code here",
                               refCode: code, actionTitle: "Modify",
                            cancelTitle: "Cancel",
                            inputPlaceholder: "Referral Code",
                            inputKeyboardType: .default, actionHandler:
                                    { (input:String?) in
                                        
                                        
                    if let referralCode = input {
                        
                        self.refCodeTextfield.text = referralCode
                        
                    }
                                            
            })
            
        }
        
        
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
