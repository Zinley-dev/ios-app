//
//  SignupViewController.swift
//  Stitchbox
//
//  Created by Anh Nguyen on 11/7/22.
//

import UIKit
import RxSwift
import RxCocoa

class RegisterViewController: UIViewController {
    
    private let registerViewModel = RegisterViewModel()
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction func tappedSignupButton(_ sender: UIButton) {
        registerViewModel.register(email: emailTextField.text!, password: passwordTextField.text!, phone: phoneTextField.text!, name: nameTextField.text!)
        print("tapped signup button")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        emailTextField.becomeFirstResponder()
        
        emailTextField.rx.text.map{ $0 ?? ""}.bind(to: registerViewModel.emailTextPublishedSubject).disposed(by: disposeBag)
        passwordTextField.rx.text.map{ $0 ?? ""}.bind(to: registerViewModel.nameTextPublishedSubject).disposed(by: disposeBag)
        phoneTextField.rx.text.map{ $0 ?? ""}.bind(to: registerViewModel.phoneTextPublishedSubject).disposed(by: disposeBag)
        nameTextField.rx.text.map{ $0 ?? ""}.bind(to: registerViewModel.nameTextPublishedSubject).disposed(by: disposeBag)
        
//        registerViewModel.isValid().bind(to: signUpButton.rx.isEnabled).disposed(by: disposeBag)
//        registerViewModel.isValid().map{ $0 ? 1: 0.2 }.bind(to: signUpButton.rx.alpha).disposed(by: disposeBag)
        
    }
    
        
    
    
    
    
    
    
    
    //MARK: - Bindings
    
}
