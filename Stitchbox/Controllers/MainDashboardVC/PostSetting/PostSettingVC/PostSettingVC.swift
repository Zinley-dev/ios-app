//
//  reportView.swift
//  Dual
//
//  Created by Khoi Nguyen on 1/16/21.
//

import UIKit

class PostSettingVC: UIViewController{
    
    @IBOutlet weak var shareView: UIView!
    
    @IBOutlet weak var cancelBtn: UIButton!
    
    @IBOutlet weak var copyLinkBtn: UIButton!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    
    @IBOutlet weak var editBtn: UIButton!
    
    @IBOutlet weak var downloadBtn: UIButton!
    
    @IBOutlet weak var shareBtn: UIButton!
    
    @IBOutlet weak var statBtn: UIButton!
    
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var showInfoStack: UIStackView!
    
    @IBOutlet weak var showInfoBtn: UIButton!
    
    var isInformationHidden = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        emptyLbl()
        
        if isInformationHidden {
            showInfoStack.isHidden = false
        } else {
            showInfoStack.isHidden = true
        }

    }
    
    
    func emptyLbl() {
        deleteBtn.setTitle("", for: .normal)
        statBtn.setTitle("", for: .normal)
        shareBtn.setTitle("", for: .normal)
        downloadBtn.setTitle("", for: .normal)
        editBtn.setTitle("", for: .normal)
        cancelBtn.setTitle("", for: .normal)
        sendBtn.setTitle("", for: .normal)
        copyLinkBtn.setTitle("", for: .normal)
        showInfoBtn.setTitle("", for: .normal)
    }
    
    
    @IBAction func showVideoInfoBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "showInfo")), object: nil)
        
        self.dismiss(animated: true)
        
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "edit")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func downloadBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "download")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func shareBtnPressed(_ sender: Any) {
        
        shareView.isHidden = false
        
    }
    
    @IBAction func statsBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "stats")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    @IBAction func deleteBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "delete")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    
    @IBAction func copyLinkBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "copyLink")), object: nil)
        self.dismiss(animated: true)
        
    }
    
    
    @IBAction func sendBtnPressed(_ sender: Any) {
        
        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "share")), object: nil)
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

