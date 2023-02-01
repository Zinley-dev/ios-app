//
//  StreamingLinkVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/28/23.
//

import UIKit

class StreamingLinkVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    var isVerified = false
    
    @IBOutlet weak var streamingLinkTxt: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if global_fullLink != "" {
            streamingLinkTxt.text = global_fullLink
        }
        
        streamingLinkTxt.delegate = self
        streamingLinkTxt.addTarget(self, action: #selector(StreamingLinkVC.textFieldDidChange(_:)), for: .editingChanged)
        setupBtn()
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        delay(0.1) {
            self.streamingLinkTxt.addUnderLine()
        }
        
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    
    @IBAction func SaveBtnPressed(_ sender: Any) {
        
        if let text = streamingLinkTxt.text, text != "", isVerified == true {
            
            
            if let url = URL(string: text) {
                
                if let domain = url.host {
                    
                    if check_Url(host: domain) == true {
                        
                        global_host = domain
                        global_fullLink = text
                        
                        isVerified = true
                        
                        if let navigationController = self.navigationController {
                            navigationController.popViewController(animated: true)
                        }
                        

                        
                        
                    } else {
                        
                        isVerified = false
                        saveBtn.backgroundColor = .disableButtonBackground
                        saveBtn.titleLabel?.textColor = .lightGray
                        streamError()
                        return
                        
                    }
                    
                }
            }
            
        }
        
    }
    

}


extension StreamingLinkVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        if let text = streamingLinkTxt.text, text != "" {
            
            if verifyUrl(urlString: text) == true {
                
                isVerified = true
                saveBtn.backgroundColor = .primary
                saveBtn.titleLabel?.textColor = .white
                
            } else {
                
                isVerified = false
                saveBtn.backgroundColor = .disableButtonBackground
                saveBtn.titleLabel?.textColor = .lightGray
                
            }
            
        } else {
            
            isVerified = false
            saveBtn.backgroundColor = .disableButtonBackground
            saveBtn.titleLabel?.textColor = .lightGray
            
        }
        
    }
    

    
    func streamError() {
        
        let alert = UIAlertController(title: "Oops!", message: "Your current streaming link isn't supported now, do you want to view available streaming link list ?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in

            let slideVC =  StreamingListVC()
            
            slideVC.modalPresentationStyle = .custom
            slideVC.transitioningDelegate = self
            global_presetingRate = Double(0.55)
            global_cornerRadius = 40
            
            
            self.present(slideVC, animated: true, completion: nil)
            
            
        }))

        self.present(alert, animated: true)
        
        
    }
    
    
}


extension StreamingLinkVC {
    
    func setupBtn() {
        
        setupBackButton()

    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Add Streaming Link", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }

    
}

extension StreamingLinkVC {
        
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func onClickAdd(_ sender: AnyObject) {
        print("Added")
    }
    
}