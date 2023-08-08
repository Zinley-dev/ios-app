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
    
    var usernameBorder = CALayer()
    var phoneBorder = CALayer()
  
    let backButton: UIButton = UIButton(type: .custom)
    
    
    lazy var LoginController: LoginController = {
        
        if let controller = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "LoginController") as? LoginController {
                    
            addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! LoginController
        }
       
        
    }()
    
    lazy var LoginByPhoneSendCodeController: LoginByPhoneSendCodeController = {
        
        
        if let controller = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "LoginByPhoneSendCodeController") as? LoginByPhoneSendCodeController {
            
    
            addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! LoginByPhoneSendCodeController
        }
                
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        // Do any additional setup after loading the view.
        setupBackButton()
    
        
        setupNavBar()
        
        
        usernameBorder = usernameBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: self.view.frame.width * (130/375))
        phoneBorder = phoneBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: self.view.frame.width * (130/375))
        
        
        setupPhoneBtn()

        
        // default load for 2 child views
        
        LoginController.view.isHidden = true
        LoginByPhoneSendCodeController.view.isHidden = false
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupNavBar()
    }
    
    func setupNavBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
    }
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back-black") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)

        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.title = "Let's get started"
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
        
        usernameBtn.setTitleColor(UIColor.black, for: .normal)
        phoneBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        usernameBtn.layer.addSublayer(usernameBorder)
        
        phoneBorder.removeFromSuperlayer()
        
        descLbl.text = "Enter your username and password"
        
        LoginController.view.isHidden = false
        LoginByPhoneSendCodeController.view.isHidden = true
         
    }
    
    func setupPhoneBtn() {
        
        usernameBtn.setTitleColor(UIColor.lightGray, for: .normal)
        phoneBtn.setTitleColor(UIColor.black, for: .normal)
        
        phoneBtn.layer.addSublayer(phoneBorder)
        
        usernameBorder.removeFromSuperlayer()
        
        descLbl.text = "Select a country and enter your phone number"
        
        LoginController.view.isHidden = true
        LoginByPhoneSendCodeController.view.isHidden = false
        
      
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    

}
