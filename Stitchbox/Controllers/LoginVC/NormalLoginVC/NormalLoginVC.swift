//
//  NormalLoginVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/6/23.
//

import UIKit

class NormalLoginVC: UIViewController {
    
    @IBOutlet weak var usernameBtn: UIButton!
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var descLbl: UILabel!
  
    let backButton: UIButton = UIButton(type: .custom)
    
    
    lazy var LoginController: LoginController = {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? LoginController {
                    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! LoginController
        }
       
        
    }()
    
    lazy var LoginByPhoneSendCodeController: LoginByPhoneSendCodeController = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginByPhoneSendCodeController") as? LoginByPhoneSendCodeController {
            
    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! LoginByPhoneSendCodeController
        }
                
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupBackButton()
        setupUsernameBtn()

        
        // default load for 2 child views
        
        LoginController.view.isHidden = false
        LoginByPhoneSendCodeController.view.isHidden = true
        
        
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

    
    @IBAction func phoneBtnPressed(_ sender: Any) {
        
        setupPhoneBtn()
        
    }
    
    
    @IBAction func usernameBtnPressed(_ sender: Any) {
        
        setupUsernameBtn()
        
    }
    
    // addChildVC Function
    
    func addVCAsChildVC(childViewController: UIViewController) {
        
        addChild(childViewController)
        contentView.addSubview(childViewController.view)
        
        childViewController.view.frame = contentView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.didMove(toParent: self)
        
        
    }
    
    func removeVCAsChildVC(childViewController: UIViewController) {
        
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
    
    
    func setupUsernameBtn() {
        
        usernameBtn.setTitleColor(UIColor.white, for: .normal)
        phoneBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
        usernameBtn.backgroundColor = UIColor.secondary
        phoneBtn.backgroundColor = UIColor.clear
        
        descLbl.text = "Enter your username and password"
        
        LoginController.view.isHidden = false
        LoginByPhoneSendCodeController.view.isHidden = true
        
       
    }
    
    func setupPhoneBtn() {
        
        usernameBtn.setTitleColor(UIColor.lightGray, for: .normal)
        phoneBtn.setTitleColor(UIColor.white, for: .normal)
        
        
        usernameBtn.backgroundColor = UIColor.clear
        phoneBtn.backgroundColor = UIColor.secondary
        
        descLbl.text = "Select a country and enter your phone number"
        
        LoginController.view.isHidden = true
        LoginByPhoneSendCodeController.view.isHidden = false
        
      
    }
    
    

}
