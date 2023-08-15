//
//  ResolutionDetailVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 8/14/23.
//

import UIKit
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices

class ResolutionDetailVC: UIViewController, ZSWTappableLabelTapDelegate {
    
    deinit {
        print("ResolutionDetailVC is being deallocated.")
    }
    
    let backButton: UIButton = UIButton(type: .custom)

    @IBOutlet weak var supportLbl: ZSWTappableLabel!
    var detailIssue: VideoIssueModel!
    
    @IBOutlet weak var actionTime: UILabel!
    @IBOutlet weak var reason: UILabel!
    
    @IBOutlet weak var detectedBy: UILabel!
    @IBOutlet weak var createdTime: UILabel!
    @IBOutlet weak var videoId: UILabel!
    
    static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
    enum LinkType: String {
      case Support = "Support"
      case TermsOfUse = "TOU"
         
          
      var URL: Foundation.URL {
          switch self {
          case .Support:
              return Foundation.URL(string: "https://stitchbox.net/contact-us")!
          case .TermsOfUse:
              return Foundation.URL(string: "https://stitchbox.net/term-of-use")!
             
          }
      }
          
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupButtons()
        setupLabel()
        reason.text = detailIssue.contentModerationMessage
        videoId.text = detailIssue.id
        configureTimeForCreation()
        configureTimeForAction()
        reason.text = detailIssue.contentModerationMessage
        detectedBy.text = "SB Automatic moderation system"
    }
    

    private func configureTimeForCreation() {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy HH:mm:ss"
        createdTime.text = dateFormatterGet.string(from: detailIssue.createdAt!)
    
    }
    
    private func configureTimeForAction() {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "MM-dd-yyyy HH:mm:ss"
        actionTime.text = dateFormatterGet.string(from: (detailIssue.moderationLog?.actionTime)!)
       
    }
  
    func setupLabel() {
        
        supportLbl.tapDelegate = self
          
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
                  ResolutionDetailVC.URLAttributeName: type.URL
              ]
          })
 
        let string = NSLocalizedString("*Please review our <link type='TOU'>terms of use</link>. If you believe there is an error or discrepancy, kindly <link type='Support'>contact our support team</link> with your videoId.", comment: "")


        supportLbl.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        
    }

    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[StartViewController.URLAttributeName] as? URL else {
            return
        }
        
        let SF = SFSafariViewController(url: URL)
        SF.modalPresentationStyle = .fullScreen
        self.present(SF, animated: true)
    }
    
}



extension ResolutionDetailVC {
    
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
        navigationItem.title = "Violation description"
        
        self.navigationItem.leftBarButtonItem = backButtonBarButton
        
        
        
    }
    
    
    func showErrorAlert(_ title: String, msg: String) {
        
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
}
