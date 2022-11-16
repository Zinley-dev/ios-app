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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    //Button
    @IBOutlet weak var signUpButton: UIButton!
    @IBAction func tappedSignupButton(_ sender: UIButton) {
        registerViewModel.register(email: emailTextField.text!, password: passwordTextField.text!, phone: phoneTextField.text!, name: nameTextField.text!)
        print("tapped signup button")
        
    }

    
    // MARK: Functions
    func bindUI(with registerViewModel: RegisterViewModel) {
        emailTextField.rx.text.orEmpty.asObservable()
            .subscribe(registerViewModel.input.email)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty.asObservable()
            .subscribe(registerViewModel.input.password)
            .disposed(by: disposeBag)
        
        phoneTextField.rx.text.orEmpty.asObservable()
            .subscribe(registerViewModel.input.phone)
            .disposed(by: disposeBag)
        
        nameTextField.rx.text.orEmpty.asObservable()
            .subscribe(registerViewModel.input.name)
            .disposed(by: disposeBag)
        
        //Binding ViewModel outputs to ViewController
        registerViewModel.output.errorsObservable
            .subscribe(onNext: { (error) in
                DispatchQueue.main.async {
                    self.presentError(error: error)
                }
            })
            .disposed(by: disposeBag)
        // Output true, segue back to dashboard
        registerViewModel.output.registerResultObservable
            .subscribe(onNext: { isTrue in
                if (isTrue){
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "", sender: self)
                    }}
            })
            .disposed(by: disposeBag)
    }
    
    func presentError(error: Error) {
        let alert = UIAlertController(title: "Error", message: error._domain, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func presentMessage(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "Return", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindUI(with: registerViewModel)
        
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

