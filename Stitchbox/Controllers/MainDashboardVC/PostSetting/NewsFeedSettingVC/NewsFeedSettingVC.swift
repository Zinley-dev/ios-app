//
//  NewsFeedSettingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 2/27/23.
//

import UIKit

class NewsFeedSettingVC: UIViewController {

    @IBOutlet weak var removeStack: UIStackView!
    @IBOutlet weak var reportStack: UIStackView!
    @IBOutlet weak var shareView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var sendBtn: UIButton!

    @IBOutlet weak var copyProfileBtn: UIButton!
    
    @IBOutlet weak var copyPostBtn: UIButton!
    
    @IBOutlet weak var reportBtn: UIButton!
    
    @IBOutlet weak var removeBtn: UIButton!
    
    var isOwner = false
    var isSearch = false
    var isHashtag = false
    var isSelected = false
    var isReels = false


    override func viewDidLoad() {
        super.viewDidLoad()
        
        emptyLbl()
        
        if isOwner {
            removeStack.isHidden = true
            reportStack.isHidden = true
        }

    }
    
    
    func emptyLbl() {
        copyProfileBtn.setTitle("", for: .normal)
        shareBtn.setTitle("", for: .normal)
        copyPostBtn.setTitle("", for: .normal)
        reportBtn.setTitle("", for: .normal)
        cancelBtn.setTitle("", for: .normal)
        sendBtn.setTitle("", for: .normal)
        removeBtn.setTitle("", for: .normal)
    }
    
    //_selected
    
    @IBAction func copyProfileBtnPressed(_ sender: Any) {
        
        if isSelected {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "copy_profile_selected")), object: nil)
        } else {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "copy_profile")), object: nil)
        }
        
        self.dismiss(animated: true)
        
    }
    
    @IBAction func copyPostBtnPressed(_ sender: Any) {
        
        if isSelected {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "copy_post_selected")), object: nil)
        }  else {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "copy_post")), object: nil)
        }
        
        self.dismiss(animated: true)
        
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        
        shareView.isHidden = false
        
    }
    
    @IBAction func reportBtnPressed(_ sender: Any) {
        
        if isSelected {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report_post_selected")), object: nil)
        } else {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report_post")), object: nil)
        }
        
       
        self.dismiss(animated: true)
        
    }
    
    @IBAction func removeBtnPressed(_ sender: Any) {
        
        if isSelected {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "remove_post_selected")), object: nil)
        } else {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "remove_post")), object: nil)
        }
        
       
        self.dismiss(animated: true)
        
    }
    
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        
        if isSelected {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "share_post_selected")), object: nil)
        } else {
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "share_post")), object: nil)
        }
        
       
        self.dismiss(animated: true)
        
    }
    
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        
        shareView.isHidden = true
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    


}
