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
    
    @IBOutlet weak var streamingLinkTxt: UITextField! {
        didSet {
            let redPlaceholderText = NSAttributedString(string: "Ex: youtube, facebook, twitch ... etc",
                                                        attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            
            streamingLinkTxt.attributedPlaceholder = redPlaceholderText
        }
    }
    
    
    
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
        
        let slideVC =  StreamingListVC()
        
        slideVC.modalPresentationStyle = .custom
        slideVC.transitioningDelegate = self
        global_presetingRate = Double(0.65)
        global_cornerRadius = 40
    
        self.present(slideVC, animated: true, completion: nil)
        
    }
    
}


extension StreamingLinkVC: UITextFieldDelegate {
    
    @objc func textFieldDidChange(_ textField: UITextField) {

        if let text = streamingLinkTxt.text, text != "" {
            
            if verifyUrl(urlString: text) == true {
                
                isVerified = true
                createSaveBtn()
                
            } else {
                
                isVerified = false
                self.navigationItem.rightBarButtonItem = nil
            }
            
        } else {
            
            isVerified = false
            self.navigationItem.rightBarButtonItem = nil
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
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back_icn_white") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        navigationItem.title = "Add Streaming Link"
       
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }
    
    func createSaveBtn() {
      
        let createButton = UIButton(type: .custom)
        createButton.addTarget(self, action: #selector(saveLink(_:)), for: .touchUpInside)
        createButton.semanticContentAttribute = .forceRightToLeft
        createButton.setTitle("Save", for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        createButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2, bottom: 0, right: -2)
        createButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: -2, bottom: 0, right: 2)
        createButton.frame = CGRect(x: 0, y: 0, width: 80, height: 30)
        createButton.backgroundColor = .primary
        createButton.cornerRadius = 15
        let customView = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 30))
        customView.addSubview(createButton)
        createButton.center = customView.center
        let createBarButton = UIBarButtonItem(customView: customView)

        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2
      
        self.navigationItem.rightBarButtonItem = createBarButton
         
    }

    
}

extension StreamingLinkVC {
        
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func saveLink(_ sender: AnyObject) {
        
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
                        /*
                        saveBtn.backgroundColor = .disableButtonBackground
                        saveBtn.titleLabel?.textColor = .lightGray
                         */
                        streamError()
                        return
                        
                    }
                    
                }
            }
            
        }
        
    }
    
    
    @objc func onClickAdd(_ sender: AnyObject) {
        print("Added")
    }
    
}
