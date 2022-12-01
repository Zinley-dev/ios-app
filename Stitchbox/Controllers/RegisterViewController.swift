//
//  SignupViewController.swift
//  Stitchbox
//
//  Created by Anh Nguyen on 11/7/22.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController, ControllerType {
    typealias ViewModelType = RegisterViewModel
    
    // MARK: Properties
    private var registerViewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    // MARK: UI
    // TextFields
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reEnterPasswordTextField: UITextField!
    //Labels
    @IBOutlet weak var minCharactersLabel: UILabel!
    @IBOutlet weak var specialCharLabel: UILabel!
    @IBOutlet weak var minLowerCaseLabel: UILabel!
    @IBOutlet weak var minUpperCaseLabel: UILabel!
    @IBOutlet weak var minNumLabel: UILabel!
    @IBOutlet weak var passwordMatchLabel: UILabel!
    //Buttons
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction func tappedSignupButton(_ sender: UIButton) {
        registerViewModel.register(password: passwordTextField.text!, userName: userNameTextField.text!)
        print("tapped signup button")
    }
    
    //MARK: Lifecyle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindUI(with: registerViewModel)
        bindAction(with: registerViewModel)
        self.enableButton(button: signUpButton, enabled: false)
        //self.signUpButton.setDefault() = true
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named: "lightBackground.png")!)
        self.reEnterPasswordTextField.isEnabled = false
    }
    
    // MARK: Functions
    
    func bindUI(with registerViewModel: RegisterViewModel) {
        
        userNameTextField.rx.text.orEmpty.asObservable()
            .subscribe(registerViewModel.input.userName)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty.asObservable()
            .subscribe(registerViewModel.input.password)
            .disposed(by: disposeBag)
        
        reEnterPasswordTextField.rx.text.orEmpty.asObservable()
            .subscribe(registerViewModel.input.reEnterPassword)
            .disposed(by: disposeBag)
        
        registerViewModel.output.validMatch.subscribe(onNext:{ isTrue in
            if(isTrue){
                self.passwordMatchLabel.textColor = UIColor.green
                self.enableButton(button: self.signUpButton, enabled: true)
            }
            else {
                self.passwordMatchLabel.textColor = UIColor.red
                self.enableButton(button: self.signUpButton, enabled: false)
            }
        })
        .disposed(by: disposeBag)
        
        registerViewModel.output.isValidPasswordObservable.subscribe(onNext: {error in
            if(error.isEmpty){
                self.minUpperCaseLabel.textColor = UIColor.gray
                self.minCharactersLabel.textColor = UIColor.gray
                self.minLowerCaseLabel.textColor = UIColor.gray
                self.minNumLabel.textColor = UIColor.gray
                self.specialCharLabel.textColor = UIColor.gray
                self.passwordMatchLabel.textColor = UIColor.gray
                
            }
            
            if (error.minUppercase){
                self.minUpperCaseLabel.textColor = UIColor.red
            }else { self.minUpperCaseLabel.textColor = UIColor.green }
            
            if (error.minCharacters){
                self.minCharactersLabel.textColor = UIColor.red
            }else { self.minCharactersLabel.textColor = UIColor.green }
            
            if (error.minNumber){
                self.minNumLabel.textColor = UIColor.red
            }else { self.minNumLabel.textColor = UIColor.green}
            
            if (error.minLowercase){
                self.minLowerCaseLabel.textColor = UIColor.red
            }else { self.minLowerCaseLabel.textColor = UIColor.green }
            
            if (error.minSpecialCharacter){
                self.specialCharLabel.textColor = UIColor.red
            }else { self.specialCharLabel.textColor = UIColor.green }
            
            if (error.minUppercase != true && error.isEmpty != true && error.minLowercase != true && error.minSpecialCharacter != true && error.minNumber != true && error.minCharacters != true) {
                self.reEnterPasswordTextField.isEnabled = true
                self.enableButton(button: self.signUpButton, enabled: false)
            }else {
                self.reEnterPasswordTextField.isEnabled = false
                self.enableButton(button: self.signUpButton, enabled: false)
            }
            
        }).disposed(by: disposeBag)
        
        //Binding ViewModel outputs to ViewController
        registerViewModel.output.errorsObservable
            .subscribe(onNext: { (error) in
                DispatchQueue.main.async {
                    self.presentError(error: error)
                }
            })
            .disposed(by: disposeBag)
        // Output true, segue back to welcomescreen
        registerViewModel.output.registerResultObservable
            .subscribe(onNext: { isTrue in
                if (isTrue){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "WelcomeScreen", sender: self)
                    }}
            })
            .disposed(by: disposeBag)
    }
    
    func bindAction(with registerViewModel: RegisterViewModel) {
        signUpButton.rx.tap.asObservable()
            .withLatestFrom(
                Observable.zip(userNameTextField.rx.text.orEmpty.asObservable(),
                               passwordTextField.rx.text.orEmpty.asObservable()
                              )
            )
            .subscribe(registerViewModel.action.registerDidTap)
            .disposed(by: disposeBag)
    }
    
    func enableButton(button: UIButton, enabled:Bool) {
        button.isEnabled = enabled
        button.backgroundColor = enabled ? UIColor.primary : UIColor.disabled
    }
    
    func enableTextField(textfield: UITextField, enabled:Bool) {
        textfield.isEnabled = enabled
        textfield.alpha = enabled ? 1.0 : 0.25
    }
    
    
}

extension RegisterViewController {
    static func create(with registerViewModel: RegisterViewModel) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "RegisterViewController") as! RegisterViewController
        controller.registerViewModel = registerViewModel
        return controller
    }
}


