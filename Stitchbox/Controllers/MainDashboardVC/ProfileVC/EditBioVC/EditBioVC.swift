//
//  EditBioVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/18/23.
// Tell other player about yourself?

import UIKit

class EditBioVC: UIViewController {

    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var bioTextView: UITextView!
    let backButton: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupDefaultBio()
        bioTextView.delegate = self
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        self.view.endEditing(true)
        
    }
    @IBAction func saveBtnPressed(_ sender: Any) {
        
        if let bio = bioTextView.text {
    
            presentSwiftLoader()
            APIManager().updateme(params: ["about": bio]) { result in
                switch result {
                case .success(let apiResponse):
                    
                    guard apiResponse.body?["message"] as? String == "success" else {
                            return
                    }
                    
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "refreshData")), object: nil)
                        showNote(text: "Updated successfully")
                    }
                  
                case .failure(let error):
                    DispatchQueue.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: error.localizedDescription)
                    }
                    
                }
            }
            
        }
        
    }
    
}

extension EditBioVC {
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        navigationItem.title = "Edit Bio"
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func setupDefaultBio() {
        
        if let about = _AppCoreData.userDataSource.value?.about, about != "" {
            bioTextView.text = about
        } else {
            bioTextView.text = "Tell other player about yourself?"
        }
        
    }
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
    
   
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    
}

extension EditBioVC: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        if bioTextView.text == "Tell other player about yourself?" {
            
            bioTextView.text = ""
            
        }
    }
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        if bioTextView.text == "" {
            
            bioTextView.text = "Tell other player about yourself?"
            
        }
        
    }
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        if bioTextView.text != "Tell other player about yourself?" {
            
            saveBtn.backgroundColor = .primary
            saveBtn.titleLabel?.textColor = .white
            
        } else {
            
            saveBtn.backgroundColor = .disableButtonBackground
            saveBtn.titleLabel?.textColor = .lightGray
           
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 1000    // 500 Limit Value
    }
    
}
