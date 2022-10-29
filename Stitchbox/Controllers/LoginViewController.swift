//
//  LoginViewController.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var lblMess: UILabel!
    
    var viewModel = LoginViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lblMess.text = viewModel.message
        bindViewModel()
    }
    
    @IBAction func btnLoginClick(_ sender: Any) {
        viewModel.login()
//        RedirectionHelper.redirectToDashboard()
    }
    
    private func bindViewModel() {
        viewModel.$message.sink { [weak self] state in
            self?.lblMess.text = state
        }
    }

}
