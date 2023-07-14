//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class EditChannelDataModView: UIViewController{
    
    deinit {
        print("EditChannelDataModView is being deallocated.")
    }
    
    @IBOutlet weak var changeNameBtn: UIButton!
    @IBOutlet weak var changeAvatarBtn: UIButton!
    @IBOutlet weak var CancelBtn: UIButton!
    
    
    var isOperator: Bool?
    var isMute: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyLbl()
        

    }
    
    
    func emptyLbl() {
        changeNameBtn.setTitle("", for: .normal)
        changeAvatarBtn.setTitle("", for: .normal)
        CancelBtn.setTitle("", for: .normal)
      
    }
    
    @IBAction func changeNameBtn(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "changeName")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func changeAvatarBtn(_ sender: Any) {
            
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "changeAvatar")), object: nil)
        self.dismiss(animated: true)
    
    }
    
    @IBAction func CancelBtn(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    
   //dismissUser
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
}
