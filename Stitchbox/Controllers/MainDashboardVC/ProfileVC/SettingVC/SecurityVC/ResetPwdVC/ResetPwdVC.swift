//
//  ResetPwdVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/18/23.
//

import UIKit
import RxSwift
import RxCocoa

class ResetPwdVC: UIViewController, ControllerType {
    typealias ViewModelType = ChangePasswordViewModel
    
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var confirmNewPwdTextField: UITextField! {
        didSet {
            let redPlaceholderText = NSAttributedString(string: "Confirm your new password",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            confirmNewPwdTextField.attributedPlaceholder = redPlaceholderText
        }
    }
    
    @IBOutlet weak var newPwdTextField: UITextField! {
        didSet {
            let redPlaceholderText = NSAttributedString(string: "Your new password",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            newPwdTextField.attributedPlaceholder = redPlaceholderText
        }
        
    }
    @IBOutlet weak var currentPwdTextField: UITextField! {
        didSet {
            let redPlaceholderText = NSAttributedString(string: "Your current password",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            currentPwdTextField.attributedPlaceholder = redPlaceholderText
        }
    }
    
    
    let backButton: UIButton = UIButton(type: .custom)
    
    let viewModel = ChangePasswordViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButtons()
    }
    func bindUI(with viewModel: ChangePasswordViewModel) {
        confirmNewPwdTextField.rx.text.subscribe{
            retypePassword in
            DispatchQueue.main.async {
                if (String(describing: retypePassword ?? "").count <= 5
                    || retypePassword != self.newPwdTextField.text
                    || String(describing: self.currentPwdTextField.text ?? "").count <= 5 ) {
                    self.saveBtn.backgroundColor = .darkGray
                    self.saveBtn.tintColor = .lightGray
                } else {
                    self.saveBtn.backgroundColor = .primary
                    self.saveBtn.tintColor = .white
                }
            }
        }.disposed(by: disposeBag)
    }
    
    func bindAction(with viewModel: ChangePasswordViewModel) {
        
        saveBtn.rx.tap.map { Void in
            (self.currentPwdTextField.text ?? "", self.newPwdTextField.text ?? "", self.confirmNewPwdTextField.text ?? "")
        }
        .bind(to: viewModel.action.changePasswordDidTap)
        .disposed(by: disposeBag)
        
        viewModel.output.resetResultObservable.subscribe{
            result in
            if result {
                DispatchQueue.main.async {
                    showNote(text: "Password changed")
                }
            }
        }.disposed(by: disposeBag)
        
        viewModel.output.errorsObservable.subscribe{ (error) in
            DispatchQueue.main.async {
                showNote(text: error)
            }
        }.disposed(by: disposeBag)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        confirmNewPwdTextField.addUnderLine()
        newPwdTextField.addUnderLine()
        currentPwdTextField.addUnderLine()
        
    }
}

extension ResetPwdVC {
    
    func setupButtons() {
        
        setupBackButton()
        
    }
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Reset Password", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}
