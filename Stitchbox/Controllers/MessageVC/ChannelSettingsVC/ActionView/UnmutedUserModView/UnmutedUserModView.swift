//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class UnmutedUserModView: UIViewController{
    
    
    @IBOutlet weak var unmutedBtn: UIButton!
    @IBOutlet weak var unmutedLbl: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyLbl()
        
        unmutedLbl.text = "  Unmute"
        
    }
    
    
    func emptyLbl() {
        unmutedBtn.setTitle("", for: .normal)
    }
    
    @IBAction func unmuteBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "MutedMember-unmuteUser")), object: nil)
       
        self.dismiss(animated: true)
        
    }
}
