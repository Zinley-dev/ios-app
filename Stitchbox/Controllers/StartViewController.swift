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

class StartViewController: UIViewController {
    private lazy var vm: StartViewModel = StartViewModel(vc: self)
    private let disposeBag = DisposeBag()

    
    @IBOutlet weak var btnLetStart: UIButton!
    @IBOutlet var collectionLoginProviders: [UIButton]!
    @IBOutlet weak var logo: UIImageView!
    
    var player: AVPlayer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        bindingUI()
    }
    
    func bindingUI() {
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
        let seleted = SocialLoginType(rawValue: sender.tag)!
        vm.startSignInProcess(with: seleted)
    }
    
    
    @objc func playVideoDidReachEnd() {
        player!.seek(to: CMTime.zero)
    }
    
}


