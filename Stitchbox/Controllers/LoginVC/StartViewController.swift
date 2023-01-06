//
//  ViewController.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit
import AVFoundation
import RxSwift
import RxCocoa
import Lottie
import ZSWTappableLabel
import ZSWTaggedString
import SafariServices

class StartViewController: UIViewController, ControllerType, ZSWTappableLabelTapDelegate {
  typealias ViewModelType = StartViewModel

  // MARK: - Properties
//  private var viewModel: ViewModelType! = ViewModelType()
  private lazy var vm: ViewModelType! = ViewModelType(vc: self)
  private let disposeBag = DisposeBag()
  
  
  @IBOutlet weak var btnLetStart: UIButton!
  @IBOutlet var collectionLoginProviders: [UIButton]!
  @IBOutlet var collectionLoginStackProviders: [UIView]!
  @IBOutlet weak var logo: UIImageView!
  @IBOutlet weak var startView: UIView!
    
  @IBOutlet weak var termOfUseLbl: ZSWTappableLabel!
  var player: AVPlayer?
  static let URLAttributeName = NSAttributedString.Key(rawValue: "URL")
    
  enum LinkType: String {
    case Privacy = "Privacy"
    case TermsOfUse = "TOU"
       
        
    var URL: Foundation.URL {
        switch self {
        case .Privacy:
            return Foundation.URL(string: "https://stitchbox.gg/")!
        case .TermsOfUse:
            return Foundation.URL(string: "https://stitchbox.gg/")!
           
        }
    }
        
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if _AppCoreData.userSession.value == nil {
      buildUI()
      bindingUI()
      
      termOfUseLbl.tapDelegate = self
        
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
                StartViewController.URLAttributeName: type.URL
            ]
        })
        
      let string = NSLocalizedString("By using any of these login option above.               You agree to our <link type='TOU'>Terms of use</link> and <link type='Privacy'>Privacy Policy</link>.", comment: "")
        
      termOfUseLbl.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        
        
    } else {
      RedirectionHelper.redirectToDashboard()
    }
    
  }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if player != nil {
            player!.play()
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playVideoDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if player != nil {
            player!.play()
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(playVideoDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if player != nil {
            player!.pause()
        }
       
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        
    }
    

    
    
    func tappableLabel(_ tappableLabel: ZSWTappableLabel, tappedAt idx: Int, withAttributes attributes: [NSAttributedString.Key : Any] = [:]) {
        guard let URL = attributes[StartViewController.URLAttributeName] as? URL else {
            return
        }
        
        let SF = SFSafariViewController(url: URL)
        SF.modalPresentationStyle = .fullScreen
        self.present(SF, animated: true)
    }
    
  
  // MARK: - Functions
  func bindUI(with: ViewModelType) {
  }
  
  func bindAction(with viewModel: ViewModelType) {
  }

  
  func bindingUI() {
    vm.output.errorsObservable
      .subscribe(onNext: { (error) in
        
        DispatchQueue.main.async {
          if (error._code == 401) {
            self.navigationController?.pushViewController(LastStepViewController.create(), animated: true)
          } else {
            self.presentError(error: error)
          }
        }
      })
      .disposed(by: disposeBag)
    
    vm.output.loginResultObservable.subscribe(onNext: { isTrue in
      if (isTrue) {
        RedirectionHelper.redirectToDashboard()
      }
    })
    .disposed(by: disposeBag)
  }
  
  func buildUI() {
    let path = Bundle.main.path(forResource: "bg", ofType: ".mp4")
    player = AVPlayer(url: URL(fileURLWithPath: path!))
    player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame = self.view.frame
    playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
    self.view.layer.insertSublayer(playerLayer, at: 0)
    player!.seek(to: CMTime.zero)
    player!.play()
    self.player?.isMuted = true
    
    //btnLetStart.layer.cornerRadius = btnLetStart.frame.height / 2
    btnLetStart.setTitle("", for: .normal)
    collectionLoginProviders.forEach { (btn) in
      btn.setTitle("", for: .normal)
    }
  
  }
  
  @IBAction func didTapLetStart(_ sender: UIButton) {
//    self.presentLoading()

      UIView.animate(withDuration: 0.3) {
          self.collectionLoginStackProviders.forEach { item in
              item.isHidden = !item.isHidden
              item.alpha = item.isHidden ? 0 : 1
          }
      }
      
  }
  
  @IBAction func didTapLogin(_ sender: UIButton) {
     
      if let seleted = SocialLoginType(rawValue: sender.tag) {
          
          vm.startSignInProcess(with: seleted)
          
      } else {
          
          print("Can't get SocialLoginType tag number to perform")
          
      }
   
  }
  
  
  @objc func playVideoDidReachEnd() {
    player!.seek(to: CMTime.zero)
  }
  
}


