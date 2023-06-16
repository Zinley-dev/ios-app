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
import AuthenticationServices
import ObjectMapper
import AppsFlyerLib

class StartViewController: UIViewController, ControllerType, ZSWTappableLabelTapDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
  typealias ViewModelType = StartViewModel

  // MARK: - Properties
//  private var viewModel: ViewModelType! = ViewModelType()
  private lazy var vm: ViewModelType! = ViewModelType(vc: self)
  private let disposeBag = DisposeBag()
  
  
    @IBOutlet weak var launchingView: UIView!
    @IBOutlet weak var blurView: UIView!
  @IBOutlet weak var contentView: UIView!
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
            return Foundation.URL(string: "https://stitchbox.gg/public-policy")!
        case .TermsOfUse:
            return Foundation.URL(string: "https://stitchbox.gg/term-of-use")!
           
        }
    }
        
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
      
    if _AppCoreData.userSession.value == nil {
        _AppCoreData.signOut()
        
        UIView.animate(withDuration: 0.5) {
            
            self.launchingView.alpha = 0
            
        }
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            
            if self.launchingView.alpha == 0 {
                
                self.launchingView.isHidden = true
                
            }
            
        }
        
        
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
        
      let string = NSLocalizedString("By using any of these login option above.               You agree to our <link type='TOU'>Terms of Use</link> and <link type='Privacy'>Privacy Policy</link>.", comment: "")
        
      termOfUseLbl.attributedText = try? ZSWTaggedString(string: string).attributedString(with: options)
        
        
        
        
    } else {
        
        self.loadNewestCoreData {
            self.loadSettings {
                RedirectionHelper.redirectToDashboard()
            }
        }
    
    }
      
    
  }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        if player != nil {
            player!.play()
            
            delay(1) {
                NotificationCenter.default.addObserver(self, selector: #selector(self.playVideoDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player!.currentItem)
            }
        
        }
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        
        if player != nil {
            player!.pause()
            
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        }

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
    self.contentView.layer.insertSublayer(playerLayer, at: 0)
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
    
  @IBAction func didTapNormalLogin(_ sender: UIButton) {
       
      //NormalLoginVC
      
      if let NLVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "NormalLoginVC") as? NormalLoginVC {
         
          self.navigationController?.pushViewController(NLVC, animated: true)
          
      }
     
  }
    
    @IBAction func didTapAppleLogin(_ sender: UIButton) {
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
            
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
        
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        if error._code != 1001 {
            self.showErrorAlert("Oops!", msg: error.localizedDescription)
        }
       
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            let userIdentifier = appleIDCredential.user
            let userFirstName = appleIDCredential.fullName?.givenName
            let userLastName = appleIDCredential.fullName?.familyName
            let userEmail = appleIDCredential.email
            
            let data = AuthResult(idToken: userIdentifier, providerID: nil, rawNonce: nil, accessToken: nil, name: "\(userFirstName ?? "") \(userLastName ?? "")", email: userEmail, phone: nil, avatar: "")

            self.vm.completeSignIn(with: data)
        }
    }
  
  
  @objc func playVideoDidReachEnd() {
    player!.seek(to: CMTime.zero)
  }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        
        let touch = touches.first
        guard let location = touch?.location(in: self.view) else { return }
        
        if !termOfUseLbl.frame.contains(location) {
            
            UIView.animate(withDuration: 0.3) {
                self.collectionLoginStackProviders.forEach { item in
                    item.isHidden = !item.isHidden
                    item.alpha = item.isHidden ? 0 : 1
                }
            }
            
        }
        
    }
  
    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
                                                                                       
        present(alert, animated: true, completion: nil)
        
    }
    
}

extension StartViewController {
    
    
    func loadSettings(completed: @escaping DownloadComplete) {
        
        APIManager.shared.getSettings { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):
            
                guard let data = apiResponse.body else {
                    completed()
                        return
                }

                let settings =  Mapper<SettingModel>().map(JSONObject: data)
                globalSetting = settings
                globalIsSound = settings?.AutoPlaySound ?? false
                
                completed()
                
            case .failure(_):
            
                completed()
               
            }
        }
        
    }
    
    
    func loadNewestCoreData(completed: @escaping DownloadComplete) {
        
        APIManager.shared.getme { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                
                if let data = response.body {
                    
                  
                    
                    if !data.isEmpty {
                    
                        if let newUserData = Mapper<UserDataSource>().map(JSON: data) {
                            _AppCoreData.reset()
                            _AppCoreData.userDataSource.accept(newUserData)
                            completed()
                        } else {
                            completed()
                        }
                        
                      
                    } else {
                        completed()
                    }
                    
                } else {
                    completed()
                }
                
                
            case .failure(let error):
                print("Error loading profile: ", error)
                completed()
            }
        }
        
        
    }
    
    
}

