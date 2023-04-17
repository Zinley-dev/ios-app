//
//  In-gameVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/15/23.
//

import UIKit

class In_gameVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate {
    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var infoBtn: UIButton!
    @IBOutlet weak var coachingBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
   
    // to override search task
    lazy var delayItem = workItem()
    
    
    lazy var In_gameInfoVC: In_gameInfoVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "In_gameInfoVC") as? In_gameInfoVC {
            
    
            self.addVCAsChildVC(childViewController: controller)

            return controller
            
        } else {
            return UIViewController() as! In_gameInfoVC
        }
       
        
    }()
    
    lazy var In_gameCoachingVC: In_gameCoachingVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "In_gameCoachingVC") as? In_gameCoachingVC {
            
          
            self.addVCAsChildVC(childViewController: controller)
            
            
            return controller
            
        } else {
            return UIViewController() as! In_gameCoachingVC
        }
                
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupInfoView()
             
    }
    
    @IBAction func infoBtnPressed(_ sender: Any) {
        
        setupInfoView()
        
    }
    
    @IBAction func coachingBtnPressed(_ sender: Any) {
        
        setupCoachingsView()
        
    }
    
    
}

extension In_gameVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupTitle()
    
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
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    
    func setupTitle() {
    
        
        navigationItem.title = "SB-Tactics"
       
       
       
    }
    
    
    func setupCoachingsView() {
        
        coachingBtn.setTitleColor(UIColor.white, for: .normal)
        infoBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
        coachingBtn.backgroundColor = UIColor.primary
        infoBtn.backgroundColor = UIColor.clear
        
        
        In_gameCoachingVC.view.isHidden = false
        In_gameInfoVC.view.isHidden = true
     
    }
    
    func setupInfoView() {
        
        coachingBtn.setTitleColor(UIColor.lightGray, for: .normal)
        infoBtn.setTitleColor(UIColor.white, for: .normal)
        
        
        coachingBtn.backgroundColor = UIColor.clear
        infoBtn.backgroundColor = UIColor.primary
        
        
        In_gameCoachingVC.view.isHidden = true
        In_gameInfoVC.view.isHidden = false
      
    }

}

extension In_gameVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
       
    }
    
    
}

extension In_gameVC {
    
    func addVCAsChildVC(childViewController: UIViewController) {
        
        addChild(childViewController)
        contentView.addSubview(childViewController.view)
        
        childViewController.view.frame = contentView.bounds
        childViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childViewController.didMove(toParent: self)
        
        
    }
    
    func removeVCAsChildVC(childViewController: UIViewController) {
        
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
    
}
