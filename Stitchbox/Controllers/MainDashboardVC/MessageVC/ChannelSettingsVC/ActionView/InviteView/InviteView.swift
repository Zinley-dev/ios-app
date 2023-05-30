//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class InviteView: UIViewController{
    
    
    @IBOutlet weak var createBtn: UIButton!
    @IBOutlet weak var inviteBtn: UIButton!
    @IBOutlet weak var cancelBtn: UIButton!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyLbl()
        
     
    }
    
    
    func emptyLbl() {
        createBtn.setTitle("", for: .normal)
        inviteBtn.setTitle("", for: .normal)
        cancelBtn.setTitle("", for: .normal)
    }
    
    @IBAction func createBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "create")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func inviteBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "invite")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
}
