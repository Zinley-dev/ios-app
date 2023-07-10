//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class DismissOperatorModView: UIViewController{
    
    deinit {
        print("DismissOperatorModView is being deallocated.")
    }
    
    @IBOutlet weak var promoteBtn: UIButton!
    @IBOutlet weak var promoteLbl: UILabel!
  
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyLbl()
        
        promoteLbl.text = "  Dismiss Operator"
        
    }
    
    
    func emptyLbl() {
        promoteBtn.setTitle("", for: .normal)
    }
    
    @IBAction func promoteBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "Operate-dismissUser")), object: nil)
       
        self.dismiss(animated: true)
        
    }
}
