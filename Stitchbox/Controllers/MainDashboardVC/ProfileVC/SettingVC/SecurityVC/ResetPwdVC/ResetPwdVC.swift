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
    
   
    @IBOutlet weak var checkPassLengthLabel: UILabel!
    @IBOutlet weak var checkPassNumberLabel: UILabel!
    @IBOutlet weak var checkPassUpperLabel: UILabel!
    @IBOutlet weak var checkPassLowerLabel: UILabel!
    @IBOutlet weak var checkPassSpecialLabel: UILabel!
    
    let backButton: UIButton = UIButton(type: .custom)
    
    let viewModel = ChangePasswordViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupButtons()
        saveBtn.isEnabled = false
    }
    func bindUI(with viewModel: ChangePasswordViewModel) {
      
        newPwdTextField.rx.text.map({$0 ?? ""}).bind(to: viewModel.input.passwordObserver).disposed(by: disposeBag)
      confirmNewPwdTextField.rx.text.map({$0 ?? ""}).bind(to: viewModel.input.rePasswordObserver).disposed(by: disposeBag)
      currentPwdTextField.rx.text.map({ $0 ?? ""}).bind(to: viewModel.input.oldPasswordObserver).disposed(by: disposeBag)
      
      viewModel.isValidInput.bind(to: saveBtn.rx.isEnabled).disposed(by: disposeBag)
      
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
                    if let navigationController = self.navigationController {
                      navigationController.popViewController(animated: true)
                    }
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
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
