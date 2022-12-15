//
//  File.swift
//  Stitchbox
//
//  Created by Khanh Duy Nguyen on 12/3/22.
//

import Foundation

//
//  SLoading.swift
//  Stitchbox
//
//  Created by Hisoft Hoangnm on 30/11/2022.
//

import UIKit
import SwiftUI
import Lottie



#if canImport(SwiftUI) && DEBUG


struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .playOnce
    
    var animationView = LottieAnimationView()
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)
        animationView.backgroundColor = .clear
        
        animationView.animation = Animation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()
        
        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)
        
        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {}
}


@available(iOS 13, *)
struct LoadingView_Preview: PreviewProvider {
    static var previews: some View {
        // view controller using programmatic UI
        VStack{
            LottieView(name: "loading-animation", loopMode: .loop)
                        .frame(width: 250, height: 250)
        }
    }
}
#endif

