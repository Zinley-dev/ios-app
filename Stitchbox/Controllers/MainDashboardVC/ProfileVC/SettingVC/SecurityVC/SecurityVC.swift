//
//  SecurityVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit

class SecurityVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var LoginActivityBtn: UIButton!
    @IBOutlet weak var twoFactorAuthBtn: UIButton!
    @IBOutlet weak var resetPasswordBtn: UIButton!
    
    var settings: SettingModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        emptyButtonsLbl()
        
    }
    
    
    @IBAction func resetPwdBtnPressed(_ sender: Any) {
        
        if let RPVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ResetPwdVC") as? ResetPwdVC {
            
            self.navigationController?.pushViewController(RPVC, animated: true)
            
        }
        
    }
    
    
    @IBAction func twoFactorAuthBtnPressed(_ sender: Any) {
        
        if let TFAVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "TwoFactorAuthVC") as? TwoFactorAuthVC {
            
            TFAVC.settings = settings
            self.navigationController?.pushViewController(TFAVC, animated: true)
            
        }
        
    }
    
    @IBAction func loginActivityBtnPressed(_ sender: Any) {
        
        if let LAVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "LoginActivityVC") as? LoginActivityVC {
            self.navigationController?.pushViewController(LAVC, animated: true)
            
        }
        
    }
    
}

extension SecurityVC {
    
    func setupButtons() {
        
        setupBackButton()
       
    }
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Security", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func emptyButtonsLbl() {
        
        LoginActivityBtn.setTitle("", for: .normal)
        twoFactorAuthBtn.setTitle("", for: .normal)
        resetPasswordBtn.setTitle("", for: .normal)
        
    }

    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}
