//
//  MainFistBumpVC.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 2/6/23.
//

import UIKit

class MainFistBumpVC: UIViewController, UINavigationBarDelegate, UINavigationControllerDelegate, UISearchBarDelegate {
    
    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var fistBumpeeBtn: UIButton!
    @IBOutlet weak var fistBumperBtn: UIButton!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewTopConstant: NSLayoutConstraint!
    @IBOutlet weak var buttonStackView: UIStackView!
    
    var searchController: UISearchController?
    var showfistBumperFirst = false
    var type = ""
    var ownerID = ""
    
    
    lazy var fistBumperVC: fistBumperVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: nil).instantiateViewController(withIdentifier: "fistBumperVC") as? fistBumperVC {
                    
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
        } else {
            return UIViewController() as! fistBumperVC
        }
       
        
    }()
    
    lazy var fistBumpeeVC: fistBumpeeVC = {
        
        
        if let controller = UIStoryboard(name: "Dashboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "fistBumpeeVC") as? fistBumpeeVC {
            
            self.addVCAsChildVC(childViewController: controller)
            
            return controller
            
        } else {
            return UIViewController() as! fistBumpeeVC
        }
                
        
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        if showfistBumperFirst
        {
            setupfistBumpersView()
        }
        else {
            setupfistBumpeeView()
        }
        setupSearchController()
        
    }
     
    
    @IBAction func fistBumperBtn(_ sender: Any) {
        
        setupfistBumpersView()
        
    }
    
    @IBAction func fistBumpeeBtn(_ sender: Any) {
        
        setupfistBumpeeView()
        
    }
    
    
}

extension MainFistBumpVC {
    
    func setupButtons() {
        
        setupBackButton()
        setupTitle()
        setupSearchBar()
    }
    
    
    func setupBackButton() {
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.sizeToFit()
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
    
        self.navigationItem.leftBarButtonItem = backButtonBarButton
       
    }
    
    func setupTitle() {
        
        guard let userDataSource = _AppCoreData.userDataSource.value else {
            print("Can't get userDataSource")
            return
        }

        let loadUsername = userDataSource.userName
        
        self.navigationItem.title = loadUsername
       
       
    }
    
    func setupSearchBar() {
        
        let searchButton: UIButton = UIButton(type: .custom)

        searchButton.setImage(UIImage(named: "search"), for: [])
        searchButton.addTarget(self, action: #selector(searchBarSetting(_:)), for: .touchUpInside)
        searchButton.frame = CGRect(x: -1, y: 0, width: 30, height: 30)
        
        let searchBarButton = UIBarButtonItem(customView: searchButton)
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 2

        self.navigationItem.rightBarButtonItem = searchBarButton
        
        
    }
    
    func setupfistBumpersView() {
        
        fistBumperBtn.setTitleColor(UIColor.white, for: .normal)
        fistBumpeeBtn.setTitleColor(UIColor.lightGray, for: .normal)
        
        
        fistBumperBtn.backgroundColor = UIColor.primary
        fistBumpeeBtn.backgroundColor = UIColor.clear
        
        
        fistBumperVC.view.isHidden = false
        fistBumpeeVC.view.isHidden = true
        
    }
    
    func setupfistBumpeeView() {
        
        fistBumperBtn.setTitleColor(UIColor.lightGray, for: .normal)
        fistBumpeeBtn.setTitleColor(UIColor.white, for: .normal)
        
        
        fistBumperBtn.backgroundColor = UIColor.clear
        fistBumpeeBtn.backgroundColor = UIColor.primary
        
        
        fistBumperVC.view.isHidden = true
        fistBumpeeVC.view.isHidden = false
        
    }
    
    func setupSearchController() {
        self.searchController = UISearchController(searchResultsController: nil)
        self.searchController?.obscuresBackgroundDuringPresentation = false
        self.searchController?.searchBar.delegate = self
        self.searchController?.searchBar.searchBarStyle = .minimal
        self.navigationItem.searchController = self.searchController
        self.navigationItem.hidesSearchBarWhenScrolling = false
        self.searchController?.searchBar.tintColor = .white
        self.searchController?.searchBar.searchTextField.textColor = .white
        self.searchController!.searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: "Search", attributes: [.foregroundColor: UIColor.lightGray])
        self.searchController!.searchBar.searchTextField.leftView?.tintColor = .lightGray
        self.searchController?.searchBar.isUserInteractionEnabled = true
        self.navigationItem.searchController = nil
        self.searchController?.searchBar.isHidden = true
    }

 
}

extension MainFistBumpVC {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        
        contentViewTopConstant.constant = 10
        
        buttonStackView.isHidden = false
        navigationItem.searchController = nil
        searchController?.searchBar.isHidden = true
       
        if fistBumperVC.view.isHidden == false {
            
            /*
            fistBumperVC.searchChannelList.removeAll()
            fistBumperVC.inSearchMode = false
            fistBumperVC.groupChannelsTableView.reloadData()
             */
            
            return
            
        }
        
        
        if fistBumpeeVC.view.isHidden == false {
            
            /*
            fistBumpeeVC.searchChannelList.removeAll()
            fistBumpeeVC.inSearchMode = false
            fistBumpeeVC.groupChannelsTableView.reloadData()
             */
            
            return
            
        }
        
        
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    
        contentViewTopConstant.constant = -50
        
        if fistBumperVC.view.isHidden == false {
            
            /*
            fistBumperVC.searchChannelList = InboxVC.channels
            fistBumperVC.inSearchMode = true
            fistBumperVC.groupChannelsTableView.reloadData()
            */
            
            return
            
        }
        
        
        if fistBumpeeVC.view.isHidden == false {
            
            /*
            fistBumpeeVC.searchChannelList = RequestVC.channels
            fistBumpeeVC.inSearchMode = true
            fistBumpeeVC.groupChannelsTableView.reloadData()
             */
            
            return
            
        }
 
    }
    
}

extension MainFistBumpVC {
    
    @objc func searchBarSetting(_ sender: AnyObject) {
        if searchController?.searchBar.isHidden == true {
            buttonStackView.isHidden = true
            navigationItem.searchController = searchController
            searchController?.searchBar.isHidden = false
            
            delay(0.025) {
                self.searchController?.searchBar.becomeFirstResponder()
            }
            
        } else {
            buttonStackView.isHidden = false
            navigationItem.searchController = nil
            searchController?.searchBar.isHidden = true
        }
    }
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}

extension MainFistBumpVC {
    
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
