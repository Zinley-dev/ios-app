//
//  StreamingIntroVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/3/23.
//

import UIKit
import SafariServices

class StreamingIntroVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var learnMoreBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
    }
    
    @IBAction func learnMoreBtnPressed(_ sender: Any) {
        let link = URL(string: "https://stitchbox.gg/")
        
        guard let URL = link else {
            return
        }
        
        let SF = SFSafariViewController(url: URL)
        SF.modalPresentationStyle = .fullScreen
        self.present(SF, animated: true)
        
    }
    

}

extension StreamingIntroVC {
    
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
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
    }
    
    @objc func onClickBack(_ sender: AnyObject) {
        
     
        self.dismiss(animated: true)
       
    }

    
}
