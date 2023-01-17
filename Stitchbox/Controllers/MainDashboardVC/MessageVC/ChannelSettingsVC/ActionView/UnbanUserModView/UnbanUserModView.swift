//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class UnbanUserModView: UIViewController{
    
    
    @IBOutlet weak var unbanBtn: UIButton!
    @IBOutlet weak var unbanLbl: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyLbl()
        
        unbanLbl.text = "  Unban"
        
    }
    
    
    func emptyLbl() {
        unbanBtn.setTitle("", for: .normal)
    }
    
    @IBAction func promoteBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "BannedMember-unbanUser")), object: nil)
       
        self.dismiss(animated: true)
        
    }
}
