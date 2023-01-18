//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class EditPostSettingsModView: UIViewController{
    
    
    @IBOutlet weak var savePostBtn: UIButton!
    @IBOutlet weak var reportPostBtn: UIButton!
    @IBOutlet weak var hidePostBtn: UIButton!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    var isMute: Bool?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isMute = !self.notificationSwitch.isOn

    }
    
    @IBAction func savePost(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "savePost")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func reportPost(_ sender: Any) {
            
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "reportPost")), object: nil)
        self.dismiss(animated: true)
        
        // show popup controller for report
        
    }
    
    @IBAction func hidePost(_ sender: Any) {
            
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "hidePost")), object: nil)
        self.dismiss(animated: true)
    
    }
    
    @IBAction func notificationChange(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "notificationChange")), object: notificationSwitch.isOn)
        self.isMute = !notificationSwitch.isOn
    }

   //dismissUser
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
}
