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
    //MARK: Properties
    private var registerViewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    func bindUI(with registerViewModel: RegisterViewModel) {
        emailTextField.rx.text.orEmpty.asObservable().subscribe(registerViewModel.input.email).disposed(by: disposeBag)
        passwordTextField.rx.text.orEmpty.asObservable().subscribe(registerViewModel.input.password).disposed(by: disposeBag)
        phoneTextField.rx.text.orEmpty.asObservable().subscribe(registerViewModel.input.phone).disposed(by: disposeBag)
        nameTextField.rx.text.orEmpty.asObservable().subscribe(registerViewModel.input.name).disposed(by: disposeBag)
        
    }
    
    
    
   
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBAction func tappedSignupButton(_ sender: UIButton) {
        registerViewModel.register(email: "popp", password: "popp", phone: "popp", name: "popp")
        print("tapped signup button")
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
