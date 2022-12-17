//
//  LoginViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 01/12/2022.
//

import UIKit
import RxSwift
import RxCocoa

class LoginViewController: UIViewController {
    typealias ViewModelType = LoginControllerViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    
    // MARK: - UI
    @IBOutlet weak var btnLogin: UIImageView!
    @IBOutlet weak var txtPassword: STextField!
    @IBOutlet weak var txtUsername: STextField!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
    }
    
    // MARK: - Functions
    func initView() {
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        let button = UIButton(type: UIButton.ButtonType.system)
        button.frame = CGRect(x: 100, y: 100, width: 200, height: 50)
        button.setTitle("Forgot   ", for: .normal)
        button.setTitleColor(UIColor(red: 233, green: 230, blue: 255, alpha: 0.8), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 13)
        button.addTarget(self, action: #selector(didTapOnForgotButton), for: UIControl.Event.touchUpInside)
        txtPassword.rightView = button
        txtPassword.rightViewMode = .always
    }
    @objc func didTapOnForgotButton() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "ForgotViewController") as! ForgotViewController
        self.navigationController?.pushViewController(controller, animated: true)
    }
    func bindUI(with: ViewModelType) {
    }
    func bindAction(with viewModel: LoginControllerViewModel) {
    }

}

extension LoginViewController {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        controller.viewModel = viewModel
        return controller
    }
}

