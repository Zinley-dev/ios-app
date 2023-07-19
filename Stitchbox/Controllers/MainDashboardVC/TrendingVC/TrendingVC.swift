//
//  TrendingVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/15/23.
//

import UIKit

class TrendingVC: UIViewController {
    
    enum TrendingMode {
        case posts
        case hashTags
    }
    
    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var hashtagBtn: UIButton!
    
    var postBorder = CALayer()
    var hashTagBorder = CALayer()
    var selectedTrendingMode = TrendingMode.posts
    
    lazy var TrendingPostVC: TrendingPostVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "TrendingPostVC") as? TrendingPostVC {
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! TrendingPostVC
        }
       
        
    }()
    
    
    
    lazy var TrendingHashtagVC: TrendingHashtagVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "TrendingHashtagVC") as? TrendingHashtagVC {
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! TrendingHashtagVC
        }
       
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavBar()
        setupLayers()
        
        postBtn.setTitleColor(UIColor.black, for: .normal)
        hashtagBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
    }
    
    func setupNavBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        navigationItem.title = "Trending"
    }
    
    func setupLayers() {
        

        postBorder = postBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: self.view.frame.width * (180/375))
        hashTagBorder = hashtagBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: self.view.frame.width * (180/375))
        
        postBtn.layer.addSublayer(postBorder)
        hashTagBorder.removeFromSuperlayer()
        TrendingHashtagVC.view.isHidden = true
        TrendingPostVC.view.isHidden = false
        
    }
    
    @IBAction func postBtnPressed(_ sender: Any) {
        
      
        postBtn.setTitleColor(UIColor.black, for: .normal)
        hashtagBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        postBtn.layer.addSublayer(postBorder)
        hashTagBorder.removeFromSuperlayer()
        TrendingHashtagVC.view.isHidden = true
        TrendingPostVC.view.isHidden = false
    }
    
    @IBAction func hashtagBtnPressed(_ sender: Any) {
        
        hashtagBtn.setTitleColor(UIColor.black, for: .normal)
        postBtn.setTitleColor(UIColor.lightGray, for: .normal)
  
        hashtagBtn.layer.addSublayer(hashTagBorder)
        postBorder.removeFromSuperlayer()
        TrendingPostVC.view.isHidden = true
        TrendingHashtagVC.view.isHidden = false
    }
    

}

extension TrendingVC {
    
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
