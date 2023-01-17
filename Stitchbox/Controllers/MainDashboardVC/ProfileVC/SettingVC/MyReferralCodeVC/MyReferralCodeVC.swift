//
//  MyReferralCodeVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 1/17/23.
//

import UIKit
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices
import AlamofireImage
import Alamofire

class MyReferralCodeVC: UIViewController {

    let backButton: UIButton = UIButton(type: .custom)
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var referralCode: UIButton!
    @IBOutlet weak var referralcodepolicy: ZSWTappableLabel!
    
    
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
    enum LinkType: String {
        case Privacy = "Privacy"
        
        var URL: Foundation.URL {
            switch self {
            case .Privacy:
                return Foundation.URL(string: "https://stitchbox.gg")!
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupPolicyLabel()
        
    }
    
    @IBAction func referralCodePressed(_ sender: Any) {
        
        
        showNote(text: "Referral code copied")
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        showNote(text: "Referral code copied")
        
    }
    
    
}

extension MyReferralCodeVC: ZSWTappableLabelTapDelegate {
    
    func setupPolicyLabel() {
        
        referralcodepolicy.tapDelegate = self
        
        let options = ZSWTaggedStringOptions()
        options["link"] = .dynamic({ tagName, tagAttributes, stringAttributes in
            guard let typeString = tagAttributes["type"] as? String,
                let type = LinkType(rawValue: typeString) else {
                    return [NSAttributedString.Key: AnyObject]()
            }
            
            return [
                .tappableRegion: true,
                .tappableHighlightedBackgroundColor: UIColor.lightGray,
                .tappableHighlightedForegroundColor: UIColor.black,
                .foregroundColor: UIColor.white,
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                MyReferralCodeVC.URLAttributeName: type.URL
            ]
        })

        
        let string = NSLocalizedString("<link type='Privacy'>Learn more about the Stitchbox referral program</link>.", comment: "")
        
        
        
        
        referralcodepolicy.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        referralcodepolicy.isUserInteractionEnabled = true
        
    }
    
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
       
        guard let URL = attributes[MyReferralCodeVC.URLAttributeName] as? URL else {
            return
        }
        
        if #available(iOS 9, *) {
            let SF = SFSafariViewController(url: URL)
            SF.modalPresentationStyle = .fullScreen
            self.present(SF, animated: true)
        } else {
            UIApplication.shared.openURL(URL)
        }
    }
    
    
    
}

//setting up navigationCollection Bar
extension MyReferralCodeVC: UINavigationBarDelegate, UINavigationControllerDelegate {
    
    func wireDelegate() {
        self.navigationController?.navigationBar.delegate = self
    }
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
    
    
}


extension MyReferralCodeVC {
    
    func setupButtons() {
        
        setupBackButton()
       
        
    }
    
    
    func setupBackButton() {
        
        
        // Do any additional setup after loading the view.
        backButton.setImage(UIImage.init(named: "back_icn_white")?.resize(targetSize: CGSize(width: 13, height: 23)), for: [])
        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.frame = CGRect(x: -10, y: 0, width: 15, height: 25)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("     Referral Code", for: .normal)
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
