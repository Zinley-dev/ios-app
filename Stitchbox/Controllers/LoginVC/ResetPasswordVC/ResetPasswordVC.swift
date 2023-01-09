//
//  ResetPasswordVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/8/23.
//

import UIKit

class ResetPasswordVC: UIViewController {
    
    @IBOutlet weak var phoneBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var descLbl: UILabel!
    let backButton: UIButton = UIButton(type: .custom)
    
    lazy var PhoneResetVC: PhoneResetVC = {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "PhoneResetVC") as? PhoneResetVC {
                    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! PhoneResetVC
        }
       
        
    }()
    
    lazy var EmailResetVC: EmailResetVC = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginByPhoneSendCodeController") as? EmailResetVC {
            
    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! EmailResetVC
        }
                
        
    }()

    @IBOutlet weak var contentView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupBackButton()
        setupPhoneBtn()

        
        // default load for 2 child views
        
        PhoneResetVC.view.isHidden = false
        EmailResetVC.view.isHidden = true
        
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
    
    
    @IBAction func EmailBtnPressed(_ sender: Any) {
        
        setupEmailBtn()
        
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
    
    
    func setupEmailBtn() {
        
        emailBtn.setTitleColor(UIColor.white, for: .normal)
        phoneBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
        emailBtn.backgroundColor = UIColor.secondary
        phoneBtn.backgroundColor = UIColor.clear
        
        descLbl.text = "Enter your email"
        
        EmailResetVC.view.isHidden = false
        PhoneResetVC.view.isHidden = true
        
       
    }
    
    func setupPhoneBtn() {
        
        emailBtn.setTitleColor(UIColor.lightGray, for: .normal)
        phoneBtn.setTitleColor(UIColor.white, for: .normal)
        
        
        emailBtn.backgroundColor = UIColor.clear
        phoneBtn.backgroundColor = UIColor.secondary
        
        descLbl.text = "Select a country and enter your phone number"
        
        EmailResetVC.view.isHidden = true
        PhoneResetVC.view.isHidden = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }

}
