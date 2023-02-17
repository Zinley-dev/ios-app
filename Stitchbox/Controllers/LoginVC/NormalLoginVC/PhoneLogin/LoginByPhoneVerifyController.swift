//  LoginByPhoneVerifyController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/30/22.
//
import Foundation
import RxSwift

class LoginByPhoneVerifyController: UIViewController, ControllerType, UITextFieldDelegate {

    typealias ViewModelType = LoginByPhoneVerifyViewModel

    // MARK: - Properties
    private var viewModel: ViewModelType! = ViewModelType()
    private let disposeBag = DisposeBag()

    // MARK: - UI
    //@IBOutlet weak var OTPTextfield: OTPStackView!
    @IBOutlet weak var PhoneNumber: UILabel!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var sendCodeButton: UIButton!
    @IBOutlet weak var openKeyBoardBtn: UIButton!
   
    
    var border1 = CALayer()
    var border2 = CALayer()
    var border3 = CALayer()
    var border4 = CALayer()
    var border5 = CALayer()
    var border6 = CALayer()
    
    
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    
    
    
    var selectedColor = UIColor.secondary
    var emptyColor = UIColor.white
    
    
    let backButton: UIButton = UIButton(type: .custom)
    @IBOutlet weak var HidenTxtView: UITextField!

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackButton()
        bindUI(with: viewModel)
        bindAction(with: viewModel)
        setupEmptyField()
    }
    
    
    @objc func openKeyBoardBtnPressed() {
        
        self.HidenTxtView.becomeFirstResponder()
        
    }
    
    func setupEmptyField() {
        
        openKeyBoardBtn.setTitle("", for: .normal)
        
        border1 = label1.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        border2 = label2.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        border3 = label3.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        border4 = label4.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        border5 = label5.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        border6 = label6.addBottomBorderWithColor(color: emptyColor, height: 2.0, width: self.view.bounds.width * (45/414) + 7)
        
        setupView()
        
        HidenTxtView.delegate = self
        HidenTxtView.keyboardType = .numberPad
        HidenTxtView.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        HidenTxtView.becomeFirstResponder()
        
        
        openKeyBoardBtn.addTarget(self, action: #selector(LoginByPhoneVerifyController.openKeyBoardBtnPressed), for: .touchUpInside)
    }
    
    
    func setupView() {
        
        label1.layer.addSublayer(border1)
        label2.layer.addSublayer(border2)
        label3.layer.addSublayer(border3)
        label4.layer.addSublayer(border4)
        label5.layer.addSublayer(border5)
        label6.layer.addSublayer(border6)
        
    }
    
    func getTextInPosition(text: String, position: Int) -> String {
        guard position < text.count else { return "Fail" }
        return String(text[text.index(text.startIndex, offsetBy: position)])
    }
    
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if HidenTxtView.text?.count == 1 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = emptyColor.cgColor
            border3.backgroundColor = emptyColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
            label1.text = getTextInPosition(text: HidenTxtView.text!, position: 0)
            label2.text = ""
            label3.text = ""
            label4.text = ""
            label5.text = ""
            label6.text = ""
            
        } else if HidenTxtView.text?.count == 2 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = emptyColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            label2.text = getTextInPosition(text: HidenTxtView.text!, position: 1)
            label3.text = ""
            label4.text = ""
            label5.text = ""
            label6.text = ""
            
        } else if HidenTxtView.text?.count == 3 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            label3.text = getTextInPosition(text: HidenTxtView.text!, position: 2)
            label4.text = ""
            label5.text = ""
            label6.text = ""
            
        } else if HidenTxtView.text?.count == 4 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = selectedColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            
            label4.text = getTextInPosition(text: HidenTxtView.text!, position: 3)
            label5.text = ""
            label6.text = ""
            
            
        } else if HidenTxtView.text?.count == 5 {
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = selectedColor.cgColor
            border5.backgroundColor = selectedColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
           
            label5.text = getTextInPosition(text: HidenTxtView.text!, position: 4)
            label6.text = ""
            
        } else if HidenTxtView.text?.count == 6 {
            
            
            border1.backgroundColor = selectedColor.cgColor
            border2.backgroundColor = selectedColor.cgColor
            border3.backgroundColor = selectedColor.cgColor
            border4.backgroundColor = selectedColor.cgColor
            border5.backgroundColor = selectedColor.cgColor
            border6.backgroundColor = selectedColor.cgColor
            
           
            label6.text = getTextInPosition(text: HidenTxtView.text!, position: 5)
            
            if let code = HidenTxtView.text, code.count == 6 {
                
                
                
            } else {
                
                border1.backgroundColor = emptyColor.cgColor
                border2.backgroundColor = emptyColor.cgColor
                border3.backgroundColor = emptyColor.cgColor
                border4.backgroundColor = emptyColor.cgColor
                border5.backgroundColor = emptyColor.cgColor
                border6.backgroundColor = emptyColor.cgColor
                
                label1.text = ""
                label2.text = ""
                label3.text = ""
                label4.text = ""
                label5.text = ""
                label6.text = ""
                
                HidenTxtView.text = ""
                
                self.showErrorAlert("Oops!", msg: "Unkown error occurs, please dismiss and fill your phone again.")
                
                
            }
            
            
        } else if HidenTxtView.text?.count == 0 {
            
            
            border1.backgroundColor = emptyColor.cgColor
            border2.backgroundColor = emptyColor.cgColor
            border3.backgroundColor = emptyColor.cgColor
            border4.backgroundColor = emptyColor.cgColor
            border5.backgroundColor = emptyColor.cgColor
            border6.backgroundColor = emptyColor.cgColor
            
            label1.text = ""
            label2.text = ""
            label3.text = ""
            label4.text = ""
            label5.text = ""
            label6.text = ""
            
        }
        
    }
    
    // func show error alert
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: {  action in
            
            self.HidenTxtView.becomeFirstResponder()
            
        }))
        
        present(alert, animated: true, completion: nil)
        
    }

    
    // MARK: - Functions
    func bindUI(with viewModel: LoginByPhoneVerifyViewModel) {
        // bind View Model outputs to Controller elements
        viewModel.output.loadingObservable.subscribe { result in
          if (result) { presentSwiftLoader() }
        }.disposed(by: disposeBag)
      
        viewModel.output.errorsObservable
        .subscribe(onNext: { (error: Error) in
                DispatchQueue.main.async {
                  if (error._code == 900) {
                    SwiftLoader.hide()
                    self.navigationController?.pushViewController(LastStepViewController.create(), animated: true)
                  } else {
                    self.presentErrorAlert(message: error.localizedDescription)
                  }
                }
            })
            .disposed(by: disposeBag)

        viewModel.output.successObservable
            .subscribe(onNext: { successMessage in
                switch successMessage{
                case .changePassword:
                    DispatchQueue.main.async {
                      SwiftLoader.hide()
                      if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "NewPasswordVC") as? NewPasswordVC {
                        self.navigationController?.pushViewController(vc, animated: true)
                      }
                    }
                case .logInSuccess:
                    RedirectionHelper.redirectToDashboard()
                case .sendCodeSuccess:
                    DispatchQueue.main.async {
                        self.presentMessage(message: "New OTP Sent Sucessfully")
                    }
                }
            })
            .disposed(by: disposeBag)
        
        
        
        PhoneNumber.text = viewModel.output.phoneNumber

    }
    func bindAction(with viewModel: LoginByPhoneVerifyViewModel) {
      sendCodeButton.rx.tap.asObservable().subscribe(viewModel.action.sendOTPDidTap).disposed(by: disposeBag)
      verifyButton.rx.tap.asObservable().map({ () in
          (self.HidenTxtView.text!)
        }).subscribe(viewModel.action.verifyOTPDidTap).disposed(by: disposeBag)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    
        
        self.view.endEditing(true)
        
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
    
}


extension LoginByPhoneVerifyController {
    static func create(with viewModel: ViewModelType) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let controller = storyboard.instantiateViewController(withIdentifier: "PHONEVERIFY") as! LoginByPhoneVerifyController
        controller.viewModel = viewModel
        controller.modalPresentationStyle = .fullScreen
        return controller
    }
}
