//
//  GradientImageNode.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/2/23.
//

import AsyncDisplayKit
import Alamofire
import swift_vibrant

class GradientImageNode: ASDisplayNode {
    
    private let gradientLayer = CAGradientLayer()
    
    override func layout() {
        super.layout()
        DispatchQueue.main.async {
            self.gradientLayer.frame = self.bounds
        }
        
    }
    
    func setGradientImage(with url: URL) {
        imageStorage.async.object(forKey: url.absoluteString) { result in
            if case .value(let image) = result {
                self.updateGradient(with: image)
            } else {
                AF.request(url).responseImage { response in
                    switch response.result {
                    case let .success(value):
                        try? imageStorage.setObject(value, forKey: url.absoluteString, expiry: .seconds(3000))
                        self.updateGradient(with: value)
                    case let .failure(error):
                        print(error)
                    }
                }
            }
        }
    }

    func updateGradient(with image: UIImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            let smallImage = image.resize(targetSize: CGSize(width: 250, height: 250))
            let palette = Vibrant.from(smallImage).getPalette()

            DispatchQueue.main.async {
                self.gradientLayer.colors = [palette.DarkMuted?.uiColor.cgColor ?? UIColor.background.cgColor,
                                             palette.DarkMuted?.uiColor.cgColor ?? UIColor.background.cgColor]
                if self.gradientLayer.superlayer == nil {
                    self.layer.addSublayer(self.gradientLayer)
                }
            }
        }
    }


}








