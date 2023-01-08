//
//  NewPasswordVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/8/23.
//

import UIKit

class NewPasswordVC: UIViewController {

    
    @IBOutlet weak var enteredPasswordTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var nextButton: SButton!
    
    @IBOutlet weak var checkPasswordMatchLabel: UILabel!
    @IBOutlet weak var checkPassLengthLabel: UILabel!
    @IBOutlet weak var checkPassNumberLabel: UILabel!
    @IBOutlet weak var checkPassUpperLabel: UILabel!
    @IBOutlet weak var checkPassLowerLabel: UILabel!
    @IBOutlet weak var checkPassSpecialLabel: UILabel!
    
    let backButton: UIButton = UIButton(type: .custom)
    

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupBackButton()
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        enteredPasswordTextfield.addUnderLine()
        passwordTextfield.addUnderLine()
    
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
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }


}
