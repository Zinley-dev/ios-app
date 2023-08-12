//
//  NewsFeedSettingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/27/23.
//

import UIKit

class StitchSettingVC: UIViewController {

    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var createNewBtn: UIButton!
    @IBOutlet weak var stitchToExistBtn: UIButton!
    var isSelected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyLbl()
        
    }
    
    
    func emptyLbl() {
        cancelBtn.setTitle("", for: .normal)
        createNewBtn.setTitle("", for: .normal)
        stitchToExistBtn.setTitle("", for: .normal)
        
    }
    
    //_selected
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        
        self.dismiss(animated: true)
        
    }
    
    @IBAction func createNewBtnPressed(_ sender: Any) {
        
        if !isSelected {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "create_new_for_stitch")), object: nil)
        } else {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "create_new_for_stitch_selected")), object: nil)
        }
      
        self.dismiss(animated: true)
        
    }
    
    @IBAction func stitchToExistPressed(_ sender: Any) {
         
        if !isSelected {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "stitch_to_exist_one")), object: nil)
        } else {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "stitch_to_exist_one_selected")), object: nil)
        }
        
        self.dismiss(animated: true)
    }
    
}
