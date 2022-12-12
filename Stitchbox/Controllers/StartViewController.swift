//
//  ViewController.swift
//  Stitchbox
//
//  Created by Nghiem Minh Hoang on 26/10/2022.
//

import UIKit
import AVFoundation
import GoogleSignIn

class StartViewController: UIViewController {

    @IBOutlet weak var btnLetStart: UIButton!
    @IBOutlet var collectionLoginProviders: [UIButton]!
    @IBOutlet weak var logo: UIImageView!
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        
    }
    
    func buildUI() {
        let path = Bundle.main.path(forResource: "bg", ofType: ".mp4")
        player = AVPlayer(url: URL(fileURLWithPath: path!))
        player?.actionAtItemEnd = AVPlayer.ActionAtItemEnd.none
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.frame
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.insertSublayer(playerLayer, at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(playVideoDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player!.currentItem)
        player!.seek(to: CMTime.zero)
        player!.play()
        self.player?.isMuted = true
        
        
        btnLetStart.layer.cornerRadius = btnLetStart.frame.height / 2
        collectionLoginProviders.forEach { (btn) in
            btn.layer.cornerRadius = btn.frame.height / 2
            btn.isHidden = true
            btn.alpha = 0
            btn.setImage(UIImage(systemName: "Apple"), for: .normal)

        }
    }
    
    @IBAction func didTapLetStart(_ sender: UIButton) {
        
        collectionLoginProviders.forEach { (btn) in
            UIView.animate(withDuration: 0.4) {
                btn.isHidden = !btn.isHidden
                btn.alpha = btn.alpha == 0 ? 1 : 0
                self.logo.isHidden = !btn.isHidden
                self.view.layoutIfNeeded()
            }
        }
            }
    
    @IBAction func didTapLogin(_ sender: UIButton) {
        print(sender.titleLabel?.text)
        
        let signInConfig = GIDConfiguration(clientID: "56078114675-c5lhtgsgsp4bod4amsc9rlfv8b4s64j8.apps.googleusercontent.com")

        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { user, error in
                guard error == nil else { return }
                guard let user = user else { return }

                if let profiledata = user.profile {
                    
                    let userId : String = user.userID ?? ""
                    let givenName : String = profiledata.givenName ?? ""
                    let familyName : String = profiledata.familyName ?? ""
                    let email : String = profiledata.email
                    
                    if let imgurl = user.profile?.imageURL(withDimension: 100) {
                        let absoluteurl : String = imgurl.absoluteString
                        //HERE CALL YOUR SERVER API
                    }
                    
                    print(userId)
                    print(givenName)
                    print(familyName)
                    print(email)
                }
                
            }
        
    }
    
    
    @objc func playVideoDidReachEnd() {
        player!.seek(to: CMTime.zero)
    }
    
}


