//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class CommentSettings: UIViewController{
    
    @IBOutlet weak var deleteStack: UIStackView!
    @IBOutlet weak var reportStack: UIStackView!
    @IBOutlet weak var unpinStack: UIStackView!
    @IBOutlet weak var pinStack: UIStackView!
    @IBOutlet weak var pinBtn: UIButton!
    
    @IBOutlet weak var unpinBtn: UIButton!
    
    @IBOutlet weak var reportBtn: UIButton!
    
    @IBOutlet weak var copyBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    

    var isPostOwner = false
    var isCommentOwner = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyLbl()
        
        if !isPostOwner {
            unpinStack.isHidden = true
            pinStack.isHidden = true
            
            if !isCommentOwner {
                deleteStack.isHidden = true
            }
            
        } else {
            reportStack.isHidden = true
        }

    }
    
    func emptyLbl() {
        deleteBtn.setTitle("", for: .normal)
        pinBtn.setTitle("", for: .normal)
        unpinBtn.setTitle("", for: .normal)
        reportBtn.setTitle("", for: .normal)
        copyBtn.setTitle("", for: .normal)
    }
    
    @IBAction func pinBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "pin_cmt")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func unpinPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "unpin_cmt")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func reportBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "report_cmt")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func copyBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "copy_cmt")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "delete_cmt")), object: nil)
        self.dismiss(animated: true)
        
    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
}

