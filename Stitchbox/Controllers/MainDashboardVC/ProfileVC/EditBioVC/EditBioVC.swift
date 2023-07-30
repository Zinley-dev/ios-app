//
//  EditBioVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/18/23.
// Tell other player about yourself?

import UIKit

class EditBioVC: UIViewController {
    
    deinit {
        print("EditBioVC is being deallocated.")
    }

    //@IBOutlet weak var saveBtn: UIButton!
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
    
}

extension EditBioVC {
    
    func setupButtons() {
        
        setupBackButton()
        createDisablePostBtn()
    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back-black")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
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
            
            createSaveBtn()
            
        } else {
            
            //saveBtn.backgroundColor = .disableButtonBackground
            //saveBtn.titleLabel?.textColor = .lightGray
            
            createDisablePostBtn()
           
        }
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).replacingCharacters(in: range, with: text)
        let numberOfChars = newText.count
        return numberOfChars <= 300    // 500 Limit Value
    }
    
    func createDisablePostBtn() {
     
        let createButton = UIButton(type: .custom)
        //createButton.addTarget(self, action: #selector(onClickPost(_:)), for: .touchUpInside)
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.setTitle("Save", for: .normal)
        createButton.setTitleColor(.lightGray, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        createButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        createButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        createButton.backgroundColor = .disableButtonBackground
        createButton.cornerRadius = 15
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(createButton)
        createButton.center = customView.center
        let createBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
      
        self.navigationItem.rightBarButtonItem = createBarButton
         
    }
    
    func createSaveBtn() {
      
        let createButton = UIButton(type: .custom)
        createButton.addTarget(self, action: #selector(onClickSave(_:)), for: .touchUpInside)
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.setTitle("Save", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        createButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        createButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        createButton.backgroundColor = .secondary
        createButton.cornerRadius = 15
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(createButton)
        createButton.center = customView.center
        let createBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
      
        self.navigationItem.rightBarButtonItem = createBarButton
         
    }
    
    
    @objc func onClickSave(_ sender: AnyObject) {
        
        if let bio = bioTextView.text {
    
            presentSwiftLoader()
            APIManager.shared.updateme(params: ["about": bio]) { [weak self] result in
                guard let self = self else { return }
                
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
