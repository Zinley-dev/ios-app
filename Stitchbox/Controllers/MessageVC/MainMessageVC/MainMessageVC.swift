//
//  InboxVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 12/16/22.
//

import UIKit
import SendBirdSDK
import SendBirdCalls


class MainMessageVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var requestBtn: UIButton!
    @IBOutlet weak var inboxBtn: UIButton!
    
    let createButton: UIButton = UIButton(type: .custom)
    
    
    // setup 2 childviews
    
    lazy var InboxVC: InboxVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "InboxViewController") as? InboxVC {
                    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! InboxVC
        }
       
        
    }()
    
    lazy var RequestVC: RequestVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "RequestViewController") as? RequestVC {
            
    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! RequestVC
        }
                
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupInboxBtn()
        settingUpLayoutNavView()
        setupRightButtons()
        
        // default load for 2 child views
        
        InboxVC.view.isHidden = false
        RequestVC.view.isHidden = true
        
    }
    
    
    // setting up navigation bar
    

    func settingUpLayoutNavView() {
        
        
        self.navigationItem.largeTitleDisplayMode = .automatic
        self.navigationController?.navigationBar.delegate = self
        
        
        navigationItem.leftBarButtonItem = nil
        navigationItem.titleView = UIView()
        navigationItem.leftBarButtonItem = self.createLeftTitleItem(text: "Messages")
        
        
        
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    func createLeftTitleItem(text: String) -> UIBarButtonItem {
        let titleLabel = UILabel()
        titleLabel.text = text
        titleLabel.font = UIFont.systemFont(ofSize: 18)
        titleLabel.textColor = UIColor.white
        return UIBarButtonItem.init(customView: titleLabel)
    }
    
    func setupRightButtons() {
        
        // Do any additional setup after loading the view.
        createButton.setImage(UIImage(named: "4x_add"), for: [])
        createButton.addTarget(self, action: #selector(showCreateChannel(_:)), for: .touchUpInside)
        createButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        let createBarButton = UIBarButtonItem(customView: createButton)
        
       
        
        self.navigationItem.rightBarButtonItems = [createBarButton]
        
        
    }
    
    @objc func showCreateChannel(_ sender: AnyObject) {
        //CreateChannelVC
        
        if let CCV = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "CreateChannelVC") as? CreateChannelVC {
             
            self.navigationController?.pushViewController(CCV, animated: true)
            
        }
        
       
    }
    
    // Buttons controll
    
    func setupInboxBtn() {
        
        inboxBtn.setTitleColor(UIColor.white, for: .normal)
        requestBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
        inboxBtn.backgroundColor = UIColor.primary
        requestBtn.backgroundColor = UIColor.clear
        
        
        InboxVC.view.isHidden = false
        RequestVC.view.isHidden = true
        
    }
    
    func setupRequestBtn() {
        
        inboxBtn.setTitleColor(UIColor.lightGray, for: .normal)
        requestBtn.setTitleColor(UIColor.white, for: .normal)
        
        
        inboxBtn.backgroundColor = UIColor.clear
        requestBtn.backgroundColor = UIColor.primary
        
        
        InboxVC.view.isHidden = true
        RequestVC.view.isHidden = false
        
    }
    

    
    @IBAction func InboxBtnPressed(_ sender: Any) {
        
        setupInboxBtn()
        
    }
    
    @IBAction func requestBtnPressed(_ sender: Any) {
        
        setupRequestBtn()
        
    }
    
    // addChildVC Function
    
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
