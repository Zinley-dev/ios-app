//
//  LoginViewController.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit
import RxSwift
import Then
import RxRealmDataSources

class LoginViewController: UIViewController {
    
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var logInByPhone: UIButton!
    @IBOutlet weak var messageView: UIView!
    
    
    private let bag = DisposeBag()
    fileprivate var viewModel: NormalLoginViewModel!
    
    //    var viewModel = UserAuthenticationModel(nil,nil,[String:])
    // in ViewDidLoad, observe the keyboardWillShow notification
    override func viewDidLoad() {
        super.viewDidLoad()
        bindUI()
    }
    
    func bindUI() {
        // Bind button to the people view controller
        viewModel.account.drive(logInButton.rx.isSelected).dispose(by: bag)
        
        // Show message when no account available
        viewModel.loggedIn
          .drive(messageView.rx.isHidden)
          .disposed(by: bag)
      }
    }
}
