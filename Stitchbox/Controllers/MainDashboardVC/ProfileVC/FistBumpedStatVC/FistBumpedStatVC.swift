//
//  FistBumpedStatVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/19/23.
//

import UIKit

class FistBumpedStatVC: UIViewController {

    @IBOutlet weak var fistBumpListBtn: UIButton!
    let backButton: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        
    }
    

}

extension FistBumpedStatVC {
    
    func setupButtons() {
        
        setupBackButton()
        fistBumpListBtn.titleLabel?.textColor = .white
    
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = back_frame
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Fistbump Stats", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
   
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

    
}
