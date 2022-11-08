//
//  LogInByPhoneViewController.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 11/8/22.
//

import Foundation
import UIKit

class LogInByPhoneViewController: UIViewController {
    
    @IBOutlet weak var lblMess: UILabel!
    
    //    var viewModel = UserAuthenticationModel(nil,nil,[String:])
    // in ViewDidLoad, observe the keyboardWillShow notification
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call the 'keyboardWillShow' function when the view controller receive the notification that a keyboard is going to be shown
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        // call the 'keyboardWillHide' function when the view controlelr receive notification that keyboard is going to be hidden
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            // if keyboard size is not available for some reason, dont do anything
            return
        }
        
        // move the root view up by the distance of keyboard height
        self.view.frame.origin.y = 0 - keyboardSize.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        // move back the root view origin to zero
        self.view.frame.origin.y = 0
    }
    
    @IBAction func btnLoginClick(_ sender: Any) {
        //        viewModel.login()
        //        RedirectionHelper.redirectToDashboard()
    }
    
    private func bindViewModel() {
        //        viewModel.$message.sink { [weak self] state in
        //            self?.lblMess.text = state
        //        }
    }
    
}
