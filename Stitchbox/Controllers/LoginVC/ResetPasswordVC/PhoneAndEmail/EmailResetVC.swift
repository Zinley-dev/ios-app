//
//  EmailResetVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/8/23.
//

import UIKit

class EmailResetVC: UIViewController {

    @IBOutlet weak var nextBtn: SButton!
    @IBOutlet weak var emailTxtField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        emailTxtField.addUnderLine()
    
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    


}
