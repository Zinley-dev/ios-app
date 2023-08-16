//
//  StitchDashboardVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 7/22/23.
//

import UIKit
import FLAnimatedImage
import AsyncDisplayKit

class StitchDashboardVC: UIViewController {
    
    let backButton: UIButton = UIButton(type: .custom)

    @IBOutlet weak var buttonStackView: UIStackView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var pendingBtn: UIButton!
    @IBOutlet weak var approvedBtn: UIButton!
    @IBOutlet weak var stitchToBtn: UIButton!
    
    @IBOutlet weak var loadingImage: FLAnimatedImageView!
    @IBOutlet weak var loadingView: UIView!
    
    
    var pendingBorder = CALayer()
    var approvedBorder = CALayer()
    var stitchToBorder = CALayer()
  
    var firstload = true
    
    
    lazy var PendingVC: PendingVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "PendingVC") as? PendingVC {
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! PendingVC
        }
       
        
    }()
    
    lazy var ApprovedStitchVC: ApprovedStitchVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "ApprovedStitchVC") as? ApprovedStitchVC {
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! ApprovedStitchVC
        }
       
        
    }()
    
    
    
    lazy var StitchToVC: StitchToVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "StitchToVC") as? StitchToVC {
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! StitchToVC
        }
       
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupNavBar()
        setupLayers()
        setupBackButton()
        
        pendingBtn.setTitleColor(UIColor.black, for: .normal)
        approvedBtn.setTitleColor(UIColor.lightGray, for: .normal)
        stitchToBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavBar()
        showMiddleBtn(vc: self)
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            do {
                if let path = Bundle.main.path(forResource: "fox2", ofType: "gif") {
                    let gifData = try Data(contentsOf: URL(fileURLWithPath: path))
                    let image = FLAnimatedImage(animatedGIFData: gifData)

                    DispatchQueue.main.async { [weak self] in
                        guard let self = self else { return }

                        self.loadingImage.animatedImage = image
                        self.loadingView.backgroundColor = self.view.backgroundColor
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        loadingView.backgroundColor = self.view.backgroundColor
        navigationController?.setNavigationBarHidden(false, animated: true)
  
        
        delay(1.5) { [weak self] in
            guard let self = self else { return }
            
            UIView.animate(withDuration: 0.5) {
                
                self.loadingView.alpha = 0
                
            }
            
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                guard let self = self else { return }
                
                if self.loadingView.alpha == 0 {
                    
                    self.loadingView.isHidden = true
                    self.loadingImage.stopAnimating()
                    self.loadingImage.animatedImage = nil
                    self.loadingImage.image = nil
                    self.loadingImage.removeFromSuperview()
                }
                
            }
            
        }
        
        if firstload {
            firstload = false
        } else {
            
            if PendingVC.view.isHidden == false {
                
                if PendingVC.currentIndex != nil {
                    PendingVC.playVideo(index: PendingVC.currentIndex!)
                }
                
            } else if StitchToVC.view.isHidden == false {
                
                if StitchToVC.currentIndex != nil {
                    StitchToVC.playVideo(index: StitchToVC.currentIndex!)
                }
                
            } else if ApprovedStitchVC.view.isHidden == false {
                
                if ApprovedStitchVC.currentIndex != nil {
                    ApprovedStitchVC.playVideo(index: ApprovedStitchVC.currentIndex!)
                }
                
            }
            
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if PendingVC.view.isHidden == false {
            
            if PendingVC.currentIndex != nil {
                PendingVC.pauseVideo(index: PendingVC.currentIndex!)
            }
            
        } else if StitchToVC.view.isHidden == false {
            
            if StitchToVC.currentIndex != nil {
                StitchToVC.pauseVideo(index: StitchToVC.currentIndex!)
            }
            
        } else if ApprovedStitchVC.view.isHidden == false {
            
            if ApprovedStitchVC.currentIndex != nil {
                ApprovedStitchVC.pauseVideo(index: ApprovedStitchVC.currentIndex!)
            }
            
        }
        
    }
    
    func setupNavBar() {
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]
        
        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
        navigationItem.title = "Stitch dashboard"
    }
    
    func setupLayers() {
        
        pendingBorder = pendingBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: self.view.frame.width * (120/375))
        stitchToBorder = stitchToBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: self.view.frame.width * (120/375))
        approvedBorder = approvedBtn.addBottomBorderWithColor(color: .secondary, height: 2.0, width: self.view.frame.width * (120/375))
        
        pendingBtn.layer.addSublayer(pendingBorder)
        
        stitchToBorder.removeFromSuperlayer()
        approvedBorder.removeFromSuperlayer()
        
        ApprovedStitchVC.view.isHidden = true
        StitchToVC.view.isHidden = true
        PendingVC.view.isHidden = false
        
       
    }
    
    @IBAction func pendingBtnPressed(_ sender: Any) {
        
      
        pendingBtn.setTitleColor(UIColor.black, for: .normal)
        stitchToBtn.setTitleColor(UIColor.lightGray, for: .normal)
        approvedBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
        
        pendingBtn.layer.addSublayer(pendingBorder)
        stitchToBorder.removeFromSuperlayer()
        approvedBorder.removeFromSuperlayer()
        
        ApprovedStitchVC.view.isHidden = true
        StitchToVC.view.isHidden = true
        PendingVC.view.isHidden = false
        
        if PendingVC.currentIndex != nil {
            PendingVC.playVideo(index: PendingVC.currentIndex!)
        }
        
        if ApprovedStitchVC.currentIndex != nil {
            ApprovedStitchVC.pauseVideo(index: ApprovedStitchVC.currentIndex!)
        }
        
        if StitchToVC.currentIndex != nil {
            StitchToVC.pauseVideo(index: StitchToVC.currentIndex!)
        }
        
    }
    
    @IBAction func approvedBtnPressed(_ sender: Any) {
        
        approvedBtn.setTitleColor(UIColor.black, for: .normal)
        pendingBtn.setTitleColor(UIColor.lightGray, for: .normal)
        stitchToBtn.setTitleColor(UIColor.lightGray, for: .normal)
  
        approvedBtn.layer.addSublayer(approvedBorder)
        stitchToBorder.removeFromSuperlayer()
        pendingBorder.removeFromSuperlayer()
        
        ApprovedStitchVC.view.isHidden = false
        StitchToVC.view.isHidden = true
        PendingVC.view.isHidden = true
        
        if PendingVC.currentIndex != nil {
            PendingVC.pauseVideo(index: PendingVC.currentIndex!)
        }
        
        if ApprovedStitchVC.currentIndex != nil {
            ApprovedStitchVC.playVideo(index: ApprovedStitchVC.currentIndex!)
        }
        
        if StitchToVC.currentIndex != nil {
            StitchToVC.pauseVideo(index: StitchToVC.currentIndex!)
        }
        
        
        
    }
    
    @IBAction func stitchToBtnPressed(_ sender: Any) {
        
        stitchToBtn.setTitleColor(UIColor.lightGray, for: .normal)
        approvedBtn.setTitleColor(UIColor.lightGray, for: .normal)
        stitchToBtn.setTitleColor(UIColor.black, for: .normal)
  
        stitchToBtn.layer.addSublayer(stitchToBorder)
        pendingBorder.removeFromSuperlayer()
        approvedBorder.removeFromSuperlayer()
        
        ApprovedStitchVC.view.isHidden = true
        StitchToVC.view.isHidden = false
        PendingVC.view.isHidden = true
        
        
        if PendingVC.currentIndex != nil {
            PendingVC.pauseVideo(index: PendingVC.currentIndex!)
        }
        
        if ApprovedStitchVC.currentIndex != nil {
            ApprovedStitchVC.pauseVideo(index: ApprovedStitchVC.currentIndex!)
        }
        
        if StitchToVC.currentIndex != nil {
            StitchToVC.playVideo(index: StitchToVC.currentIndex!)
        }
        
        
       
    }
    

}

extension StitchDashboardVC {
    
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

extension StitchDashboardVC {
    
    func setupButtons() {
        
        setupBackButton()
      
        
    }
    
    
    func setupBackButton() {
        
        backButton.frame = back_frame
        backButton.contentMode = .center
        
        if let backImage = UIImage(named: "back-black") {
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
        navigationItem.title = "Pending stitches"
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

}

extension StitchDashboardVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }

}
