//
//  SubcriptionVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/12/23.
//

import UIKit
import ZSWTappableLabel
import ZSWTaggedString
import Qonversion
import SafariServices

class SubcriptionVC: UIViewController, ZSWTappableLabelTapDelegate {

    @IBOutlet weak var termOfUseLbl: ZSWTappableLabel!
    @IBOutlet weak var AnuallyPrice: UILabel!
    @IBOutlet weak var sixMonthsPrice: UILabel!
    @IBOutlet weak var monthlyPrice: UILabel!
    @IBOutlet weak var annualView: UIView!
    @IBOutlet weak var sixMonthsView: UIView!
    @IBOutlet weak var monthlyView: UIView!
    let backButton: UIButton = UIButton(type: .custom)
    var products = [Qonversion.Product]()
    var selectedIndex = 2
    
    
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
      
    enum LinkType: String {
      case Privacy = "Privacy"
      case TermsOfUse = "TOU"
         
          
      var URL: Foundation.URL {
          switch self {
          case .Privacy:
              return Foundation.URL(string: "https://stitchbox.net/privacy-policy")!
          case .TermsOfUse:
              return Foundation.URL(string: "https://stitchbox.net/term-of-use")!
             
          }
      }
          
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        termOfUseLbl.tapDelegate = self
          
          let options = ZSWTaggedStringOptions()
          options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
              guard let typeString = tagAttributes["type"] as? String,
                  let type = LinkType(rawValue: typeString) else {
                      return [NSAttributedString.Key: AnyObject]()
              }
              
              return [
                  .tappableRegion: true,
                  .tappableHighlightedBackgroundColor: UIColor.darkGray,
                  .tappableHighlightedForegroundColor: UIColor.black,
                  .foregroundColor: UIColor.black,
                  .underlineStyle: NSUnderlineStyle.single.rawValue,
                  SubcriptionVC.URLAttributeName: type.URL
              ]
          })
          
        let string = NSLocalizedString("By using any of these plans option above. You agree to our <link type='TOU'>Terms of Use</link> and <link type='Privacy'>Privacy Policy</link>.", comment: "")
          
        termOfUseLbl.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        
        
        setupButtons()
        setupDefaultPlan()
        setupTapGestures()
        loadPlans()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithOpaqueBackground()
        navigationBarAppearance.backgroundColor = .white
        navigationBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.black]

        self.navigationController?.navigationBar.standardAppearance = navigationBarAppearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
        
    }
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[StartViewController.URLAttributeName] as? URL else {
            return
        }
        
        let SF = SFSafariViewController(url: URL)
        SF.modalPresentationStyle = .fullScreen
        self.present(SF, animated: true)
    }
    
    
    func loadPlans() {
        
        IAPManager.shared.displayProduct { products in
            if !products.isEmpty {
                
                self.products = products
                
            } else {
                self.dismiss(animated: true)
            }
        }
        
    }
    

    @IBAction func purchaseBtnPressed(_ sender: Any) {
        
        IAPManager.shared.purchase(product: products[selectedIndex]) { result in
            if result {
                
                self.dismiss(animated: true)
                showNote(text: "You are Pro now!")
                
            }
        }
        
    }
    
}

extension SubcriptionVC {
    
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
        navigationItem.title = "SB Pro+"

        self.navigationItem.leftBarButtonItem = backButtonBarButton

    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

    
}

extension SubcriptionVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        self.dismiss(animated: true)
    }
    
}

extension SubcriptionVC {

    func setupDefaultPlan() {
        annualView.backgroundColor = .lightGray
        sixMonthsView.backgroundColor = .clear
        monthlyView.backgroundColor = .clear
    }

    func setupTapGestures() {
        let annualTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSubscriptionTap(_:)))
        let sixMonthsTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSubscriptionTap(_:)))
        let monthlyTap = UITapGestureRecognizer(target: self, action: #selector(self.handleSubscriptionTap(_:)))

        annualView.addGestureRecognizer(annualTap)
        sixMonthsView.addGestureRecognizer(sixMonthsTap)
        monthlyView.addGestureRecognizer(monthlyTap)
    }
    
    @objc func handleSubscriptionTap(_ sender: UITapGestureRecognizer) {
        switch sender.view {
        case annualView:
            annualView.backgroundColor = .lightGray
            sixMonthsView.backgroundColor = .clear
            monthlyView.backgroundColor = .clear
            selectedIndex = 2
        case sixMonthsView:
            annualView.backgroundColor = .clear
            sixMonthsView.backgroundColor = .lightGray
            monthlyView.backgroundColor = .clear
            selectedIndex = 1
        case monthlyView:
            annualView.backgroundColor = .clear
            sixMonthsView.backgroundColor = .clear
            monthlyView.backgroundColor = .lightGray
            selectedIndex = 0
        default:
            break
        }
    }
    
}
