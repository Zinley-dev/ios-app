//
//  ResetPasswordViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 1/8/23.
//

import RxCocoa
import RxSwift
import EzPopup

class ChangePasswordViewController: UIViewController, ControllerType {
    
    
    typealias ViewModelType = ChangePasswordViewModel
    
    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()
    private var finishBtn: UIButton?
    
    @IBOutlet var oldPassword: UITextField?
    @IBOutlet var newPassword: UITextField?
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        presentLoading()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        setUpNavigationBar()
        
        finishBtn = UIButton(type: .custom)
        finishBtn?.setImage(UIImage(named: "checkmark"), for: .normal)
        finishBtn?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        
        let item1 = UIBarButtonItem(customView: finishBtn!)
        
        
         let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard (_:)))
        self.view.addGestureRecognizer(tapGesture)
        
        self.navigationItem.setRightBarButton(item1, animated: true)
    }
    func bindUI(with viewModel: ChangePasswordViewModel) {
        viewModel.output.errorsObservable
            .subscribe(onNext: { (error: Error) in
                DispatchQueue.main.async {
                    if (error._code == 900) {
//                        self.navigationController?.pushViewController(CreateAccountViewController.create(), animated: true)
                    } else {
                        self.presentError(error: error)
                    }
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.output.successObservable
            .subscribe(onNext: { successMessage in
                if successMessage{
                    self.dismissKeyboard()
                }else{
                        self.presentMessage(message: "Cannot change password")
                }
            })
            .disposed(by: disposeBag)
        
        
    }
    
    func bindAction(with viewModel: ChangePasswordViewModel) {
        finishBtn?.rx.tap.subscribe(onDisposed: {
            guard let oldPass = self.oldPassword?.text else {
                return
            }
            guard let newPass = self.newPassword?.text else {
                return
            }
            
            viewModel.action.didTapChangePassword.onNext((oldPass,newPass))
        }).disposed(by: disposeBag)
    }
    
    // MARK: - UI
    
    
    
    @objc func dismissKeyboard (_ sender: UITapGestureRecognizer) {
        DispatchQueue.main.async {
            self.oldPassword?.resignFirstResponder()
            self.newPassword?.resignFirstResponder()
        }
    }
    
}

