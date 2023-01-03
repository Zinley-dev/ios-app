//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class ModActionView: UIViewController{
    
    
    @IBOutlet weak var promoteBtn: UIButton!
    @IBOutlet weak var muteBtn: UIButton!
    @IBOutlet weak var banBtn: UIButton!
    @IBOutlet weak var promoteLbl: UILabel!
    @IBOutlet weak var muteLbl: UILabel!
    
    var isOperator: Bool?
    var isMute: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyLbl()
        
        if isOperator! {
            promoteLbl.text = "  Dismiss Operator"
        } else {
            promoteLbl.text = "  Promote to Operator"
        }
        
        
        if isMute! {
            muteLbl.text = "  Unmute"
        } else {
            muteLbl.text = "  Mute"
        }
    }
    
    
    func emptyLbl() {
        promoteBtn.setTitle("", for: .normal)
        muteBtn.setTitle("", for: .normal)
        banBtn.setTitle("", for: .normal)
      
    }
    
    @IBAction func promoteBtnPressed(_ sender: Any) {
        
        if isOperator! {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "dismissUser")), object: nil)
        } else {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "promoteUser")), object: nil)
        }
       
        self.dismiss(animated: true)
        
    }
    
    @IBAction func muteBtnPressed(_ sender: Any) {
        
        if isMute! {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "unMuteUser")), object: nil)
        } else {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "muteUser")), object: nil)
        }
        
    
        self.dismiss(animated: true)
    
    }
    
    @IBAction func banBtn(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "banUser")), object: nil)
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
