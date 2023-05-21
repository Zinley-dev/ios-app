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
        print("DEBUG")
        print(_AppCoreData.userDataSource.value?.toJSON())
        // Do any additional setup after loading the view.
        setupButtons()
        setupPolicyLabel()
        getDefaultCode()
        referralCode?.titleLabel?.text = _AppCoreData.userDataSource.value?.referralCode
        
        if let avatarURL =  _AppCoreData.userDataSource.value?.avatarURL, avatarURL != "" {
            avatarImage?.load(url: URL(string: avatarURL)!, str: avatarURL)
        } else {
            avatarImage.image = UIImage.init(named: "defaultuser")
        }
        
        
        
    }
    
    @IBAction func referralCodePressed(_ sender: Any) {
        showNote(text: "Referral code copied")
        UIPasteboard.general.string = _AppCoreData.userDataSource.value?.referralCode ?? ""
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        showNote(text: "Referral code copied")
        UIPasteboard.general.string = _AppCoreData.userDataSource.value?.referralCode ?? ""
        
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


extension MyReferralCodeVC {
    
    func setupButtons() {
        
        setupBackButton()
        
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
        navigationItem.title = "Referral Code"
        let backButtonBarButton = UIBarButtonItem(customView: backButton)

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }
    
    func getDefaultCode() {
        
        
        guard let userDataSource = _AppCoreData.userDataSource.value, let userUID = userDataSource.userID, userUID != "" else {
            print("Sendbird: Can't get userUID")
            return
        }
        let code = userDataSource.referralCode
        if code != "" {
            referralCode.setTitle(code, for: .normal)
        }
        
    }
    
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
    
}
