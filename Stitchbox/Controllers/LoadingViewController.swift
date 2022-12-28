//
//  LoadingViewController.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 23/12/2022.
//

import UIKit
import Lottie

class LoadingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let ovlayView = UIView(frame: UIScreen.main.bounds)
        var animationView = LottieAnimationView()
        animationView.backgroundColor = .none
        animationView.animation = .named("loading-animation")
        animationView.loopMode = .loop
        animationView.animationSpeed = 1.5
        animationView.frame = CGRect(x: ovlayView.center.x - 30, y: ovlayView.center.y - 30, width: 60, height: 60)
        animationView.play()
        ovlayView.addSubview(animationView)
        self.view = ovlayView
    }
  

}
