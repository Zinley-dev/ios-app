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
    
    /*
    override init() {
        super.init()
        
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        DispatchQueue.main.async {
            self.layer.addSublayer(self.gradientLayer)
        }
       
    } */
    
    override func layout() {
        super.layout()
        DispatchQueue.main.async {
            self.gradientLayer.frame = self.bounds
        }
        
    }
    
    func setGradientImage(with url: URL) {
        
        
        imageStorage.async.object(forKey: url.absoluteString) { result in
            if case .value(let image) = result {
                
        
                DispatchQueue.main.async {
                    let palletes = Vibrant.from(image).getPalette()
                    
                    self.gradientLayer.colors = [palletes.DarkMuted?.uiColor.cgColor ?? UIColor.background.cgColor, palletes.DarkMuted?.uiColor.cgColor ?? UIColor.background.cgColor]
                    self.gradientLayer.locations = [0.0, 1.0]
                    self.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                    self.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
                    
                    self.layer.addSublayer(self.gradientLayer)
                }
                
               
               
            } else {
                
                
             AF.request(url).responseImage { response in
                    
                    
                    switch response.result {
                    case let .success(value):
                     
                        try? imageStorage.setObject(value, forKey: url.absoluteString)
                        
                        DispatchQueue.main.async {
                            let palletes = Vibrant.from(value).getPalette()
                            
                            self.gradientLayer.colors = [palletes.DarkMuted?.uiColor.cgColor ?? UIColor.background.cgColor, palletes.DarkMuted?.uiColor.cgColor ?? UIColor.background.cgColor]
                            self.gradientLayer.locations = [0.0, 1.0]
                            self.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
                            self.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
                            
                            self.layer.addSublayer(self.gradientLayer)
                        }
                        
                        
                        
                    case let .failure(error):
                        print(error)
                    }
                    
                    
                    
                }
                
            }
            
        }
    
    }



}








