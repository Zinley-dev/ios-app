//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class UserSettingVC: UIViewController {
    
    @IBOutlet weak var copyProfileBtn: UIButton!
    
    @IBOutlet weak var reportBtn: UIButton!
    
    @IBOutlet weak var blockBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        emptyLbl()
        

    }
    
    
    func emptyLbl() {
        
        copyProfileBtn.setTitle("", for: .normal)
        reportBtn.setTitle("", for: .normal)
        blockBtn.setTitle("", for: .normal)
    }
    
    @IBAction func copyProfileBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "copy_user")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func reportBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report_user")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func blockBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "block_user")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
}

