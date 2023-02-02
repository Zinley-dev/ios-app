//
//  FeedViewController.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit

class FeedViewController: UIViewController {

    @IBOutlet weak var lblHome: UILabel!
    @IBOutlet weak var progressBar: ProgressBar!
    
    let homeButton: UIButton = UIButton(type: .custom)
    
    var post_list = [PostModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        lblHome.text = _AppCoreData.userDataSource.value?.userName
        setupButtons()
                
        
        NotificationCenter.default.addObserver(self, selector: #selector(FeedViewController.updateProgressBar), name: (NSNotification.Name(rawValue: "updateProgressBar2")), object: nil)
        
    }
     

}

extension FeedViewController {
    
    @objc func updateProgressBar() {
        
        
        if (global_percentComplete == 0.00) || (global_percentComplete == 100.0) {
            
            DispatchQueue.main.async {
                self.progressBar.isHidden = true
               
            }
            global_percentComplete = 0.00
            
        } else {
            
            
            DispatchQueue.main.async {
                self.progressBar.isHidden = false
                self.progressBar.progress = (CGFloat(global_percentComplete)/100)
               
            }

        }
        
    }
    
}

extension FeedViewController {
    
    func setupButtons() {
        
        setupHomeButton()
        setupNotiButton()
    }
    
    
    func setupHomeButton() {
        
        // Do any additional setup after loading the view.
        homeButton.setImage(UIImage.init(named: "Logo")?.resize(targetSize: CGSize(width: 35, height: 35)), for: [])
        homeButton.addTarget(self, action: #selector(onClickHome(_:)), for: .touchUpInside)
        homeButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        homeButton.setTitleColor(UIColor.white, for: .normal)
        homeButton.setTitle("", for: .normal)
        homeButton.sizeToFit()
        let homeButtonBarButton = UIBarButtonItem(customView: homeButton)
    
        self.navigationItem.leftBarButtonItem = homeButtonBarButton
       
    }
    
    
    func setupNotiButton() {
        
        let notiButton: UIButton = UIButton(type: .custom)
        // Do any additional setup after loading the view.
        notiButton.setImage(UIImage.init(named: "homeNoti")?.resize(targetSize: CGSize(width: 35, height: 35)), for: [])
        notiButton.addTarget(self, action: #selector(onClickNoti(_:)), for: .touchUpInside)
        notiButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        notiButton.setTitleColor(UIColor.white, for: .normal)
        notiButton.setTitle("", for: .normal)
        notiButton.sizeToFit()
        let notiButtonBarButton = UIBarButtonItem(customView: notiButton)
    
        self.navigationItem.rightBarButtonItem = notiButtonBarButton
       
    }
    
}

extension FeedViewController {
    
    @objc func onClickHome(_ sender: AnyObject) {
        print("onClickHome")
    }
    
    @objc func onClickNoti(_ sender: AnyObject) {
        if let NVC = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "NotificationVC") as? NotificationVC {
            
            self.navigationController?.pushViewController(NVC, animated: true)
            
        }
    }
    
}
