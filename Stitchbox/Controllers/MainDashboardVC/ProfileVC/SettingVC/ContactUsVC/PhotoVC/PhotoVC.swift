//
//  PhotoVC.swift
//  The Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit

class PhotoVC: UIViewController {
    
    deinit {
        print("PhotoVC is being deallocated.")
    }

    var selectedImg: UIImage!
    var selectedIndex: Int!
    @IBOutlet weak var selectedImgView: UIImageView!
    let backButton: UIButton = UIButton(type: .custom)
    let deleteButton: UIButton = UIButton(type: .custom)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupInitialSetup()
        setupButtons()
        
    }
    
}

extension PhotoVC {
    
    func setupInitialSetup() {
        
        if let img = selectedImg {
            selectedImgView.image = img
        }
        
    }
    
    func setupButtons() {
        
        setupBackButton()
        setupDeleteButton()
        
    }
    
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back-black")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Support Image", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func setupDeleteButton() {
        
        deleteButton.setImage(UIImage.init(named: "btnCallEnd")?.resize(targetSize: CGSize(width: 30, height: 30)), for: [])
        deleteButton.addTarget(self, action: #selector(onClickDelete(_:)), for: .touchUpInside)
        deleteButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        deleteButton.setTitleColor(UIColor.white, for: .normal)
        deleteButton.setTitle("", for: .normal)
        deleteButton.sizeToFit()
        let deleteButtonBarButton = UIBarButtonItem(customView: deleteButton)
    
        self.navigationItem.rightBarButtonItem = deleteButtonBarButton
        
    }

    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    @objc func onClickDelete(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
            NotificationCenter.default.post(name: (NSNotification.Name(rawValue: "DeleteImg")), object: nil)
        }
    }
    
    
}
