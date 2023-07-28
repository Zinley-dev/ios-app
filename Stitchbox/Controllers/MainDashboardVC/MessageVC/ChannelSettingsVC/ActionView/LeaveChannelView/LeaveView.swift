//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class LeaveView: UIViewController {
    
    deinit {
        print("LeaveView is being deallocated.")
    }
    
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var leaveBtn: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()

        leaveBtn.setTitleColor(UIColor.white, for: .normal)
        cancelBtn.setTitleColor(UIColor.secondary, for: .normal)
        
    }
    
    @IBAction func leaveBtnPressed(_ sender: Any) {
        
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "leaveChannel")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        
        
        self.dismiss(animated: true)
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
}
