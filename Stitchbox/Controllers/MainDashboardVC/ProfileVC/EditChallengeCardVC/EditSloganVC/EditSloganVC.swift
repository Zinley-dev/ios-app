//
//  EditSloganVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/20/23.
//

import UIKit

class EditSloganVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    
    
    @IBOutlet weak var sloganTextField: UITextField! {
        didSet {
            let redPlaceholderText = NSAttributedString(string: "Best adc NA?",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            sloganTextField.attributedPlaceholder = redPlaceholderText
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        delay(0.1) {
            self.sloganTextField.addUnderLine()
        }
      
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }

}

extension EditSloganVC {
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Edit Slogan", for: .normal)
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
