//
//  ImageUtil.swift
//  SendBird-iOS
//
//  Created by Minhyuk Kim on 23/07/2019.
//  Copyright © 2019 SendBird. All rights reserved.
//

import UIKit
import SendBirdSDK
import Alamofire
import AlamofireImage

class ImageUtil {
    static func transformUserProfileImage(user: SBDUser) -> String {
        if let profileUrl = user.profileUrl {
            if profileUrl.hasPrefix("https://sendbird.com/main/img/profiles") {
                return ""
            }
            else {
                return profileUrl
            }
        }
        
        return ""
    }
    
    static func getDefaultUserProfileImage(user: SBDUser) -> UIImage? {
        if let nickname = user.nickname, let image = UIImage(named: "img_default_profile_image_\(nickname.count % 4)") {
            return image
        }
        
        return UIImage(named: "img_default_profile_image_1")
    }
}

extension UIButton {
    func setImageWithCache(from url: URL) {
        let cacheKey = url.absoluteString
        
        imageStorage.async.object(forKey: cacheKey) { result in
            if case .value(let image) = result {
                
               
                DispatchQueue.main.async {
                    let resize = image.resize(targetSize: CGSize(width: self.bounds.width - 15, height: self.bounds.height - 15))
                    self.setImage(resize, for: .normal)
                    self.imageView?.backgroundColor = .clear
                    self.imageView?.contentMode = .scaleAspectFit
                    self.layer.cornerRadius = self.bounds.size.width / 2
                    self.clipsToBounds = true
                }
               
            } else {
                
                AF.request(url).responseImage { response in
                                      
                   switch response.result {
                    case let .success(value):
                       
                      
                       DispatchQueue.main.async {
                           let resize = value.resize(targetSize: CGSize(width: self.bounds.width - 15, height: self.bounds.height - 15))
                           self.setImage(resize, for: .normal)
                           self.imageView?.backgroundColor = .clear
                           self.imageView?.contentMode = .scaleAspectFit
                           self.layer.cornerRadius = self.bounds.size.width / 2
                           self.clipsToBounds = true
                       }
                       
                       try? imageStorage.setObject(value, forKey: cacheKey, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                          
                           case let .failure(error):
                               print(error)
                        }
                                      
                  }
                
            }
        }
    }
}


extension UIImageView {
    convenience init(withUser user: SBDUser) {
        self.init()
        setProfileImageView(for: user)
    }
    
    func setProfileImageView(for user: SBDUser) {
        if let url = URL(string: ImageUtil.transformUserProfileImage(user: user)){
            //self.af_setImage(withURL: url, placeholderImage: ImageUtil.getDefaultUserProfileImage(user: user))
            self.af.setImage(withURL: url)
        }
        else {
            self.image = ImageUtil.getDefaultUserProfileImage(user: user)
        }
    }
    
    func load(url: URL, str: String) {
        
        imageStorage.async.object(forKey: str) { result in
            if case .value(let image) = result {
                
                DispatchQueue.main.async {
                    self.image = image
                }
               
                
            } else {
                
                AF.request(url).responseImage { response in
                                      
                   switch response.result {
                    case let .success(value):
                       DispatchQueue.main.async {
                           self.image = value
                       }
                       try? imageStorage.setObject(value, forKey: str, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                          
                           case let .failure(error):
                               print(error)
                                self.image = UIImage.init(named: "defaultuser")
                        }
                    
                    
                                      
                  }
                
            }
        }
  
    }
    
    func loadProfileContent(url: URL, str: String) {
 
        imageStorage.async.object(forKey: str) { result in
            if case .value(let image) = result {
                
                DispatchQueue.main.async {
                    self.image = image
                }
               
                
            } else {
                
                AF.request(url).responseImage { response in
                                      
                   switch response.result {
                    case let .success(value):
                       DispatchQueue.main.async {
                           self.image = value
                       }
                       try? imageStorage.setObject(value, forKey: str, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                          
                           case let .failure(error):
                               print(error)
                                self.image = UIImage.init(named: "empty")
                        }
                  
                  }
                
            }
        }
  
    }
    
    func loadGame(url: URL) {
        
        let cacheKey = url.absoluteString
        
        imageStorage.async.object(forKey: cacheKey) { result in
            if case .value(let image) = result {
                
               
                DispatchQueue.main.async {
                    let resize = image.resize(targetSize: CGSize(width: self.bounds.width - 15, height: self.bounds.height - 15))
                    self.image = resize
                    self.backgroundColor = .clear
                    self.contentMode = .scaleAspectFit
                    self.layer.cornerRadius = self.bounds.size.width / 2
                    self.clipsToBounds = true
                }
               
            } else {
                
                AF.request(url).responseImage { response in
                                      
                   switch response.result {
                    case let .success(value):
                       
                      
                       DispatchQueue.main.async {
                           let resize = value.resize(targetSize: CGSize(width: self.bounds.width - 15, height: self.bounds.height - 15))
                           self.image = resize
                           self.backgroundColor = .clear
                           self.contentMode = .scaleAspectFit
                           self.layer.cornerRadius = self.bounds.size.width / 2
                           self.clipsToBounds = true
                       }
                       
                       try? imageStorage.setObject(value, forKey: cacheKey, expiry: .date(Date().addingTimeInterval(2 * 3600)))
                                          
                           case let .failure(error):
                               print(error)
                        }
                                      
                  }
                
            }
        }
  
    }
    
}

class ProfileImageView: UIView {
    
    var users: [SBDUser] = [] {
        didSet {
            let index = (users.count > 3) ? 4 : users.count
            users = Array(users[0..<index])
            setUpImageStack()
        }
    }
    
    var spacing: CGFloat = 0 {
        didSet {
            for subView in self.subviews{
                if let stack = subView as? UIStackView{
                    for subStack in stack.arrangedSubviews{
                        (subStack as? UIStackView)?.spacing = spacing
                    }
                }
                (subView as? UIStackView)?.spacing = spacing
            }
        }
    }
    
    func makeCircularWithSpacing(spacing: CGFloat){
        self.layer.cornerRadius = self.frame.height/2
        self.spacing = spacing
    }
    
    private func setUpImageStack() {
        for subView in self.subviews{
            subView.removeFromSuperview()
        }
        
        let mainStackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        mainStackView.axis = .horizontal
        mainStackView.spacing = spacing
        mainStackView.distribution = .fillEqually
        self.addSubview(mainStackView)
        
        if users.isEmpty {
            let imageContainerView = UIView(frame: self.frame)
            let imageView = UIImageView(image: UIImage(named: "img_default_profile_image_1"))
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageContainerView.translatesAutoresizingMaskIntoConstraints = false
            
            imageContainerView.addSubview(imageView)
            mainStackView.addArrangedSubview(imageContainerView)
            
            imageView.heightAnchor.constraint(equalTo: imageContainerView.heightAnchor).isActive = true
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
            
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor).isActive = true
            imageContainerView.clipsToBounds = true
            
            
        }
        
        for user in users{
            let imageContainerView = UIView(frame: self.frame)
            let imageView = UIImageView(withUser: user)
            imageContainerView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageContainerView.translatesAutoresizingMaskIntoConstraints = false
            if users.count == 1 {
                mainStackView.addArrangedSubview(imageContainerView)
            }
            else {
                
                let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
                stackView.addArrangedSubview(imageContainerView)
                stackView.axis = .vertical
                stackView.distribution = .fillEqually
                stackView.spacing = spacing
                
                imageView.heightAnchor.constraint(equalToConstant: imageContainerView.frame.height).isActive = true
                imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor).isActive = true
                
                if mainStackView.arrangedSubviews.count < 2 {
                    mainStackView.addArrangedSubview(stackView)
                }
                else {
                    for subView in mainStackView.arrangedSubviews {
                        if (subView as? UIStackView)?.arrangedSubviews.count == 1 {
                            (subView as? UIStackView)?.addArrangedSubview(imageContainerView)
                        }
                    }
                }
            }
            
            imageView.centerXAnchor.constraint(equalTo: imageContainerView.centerXAnchor).isActive = true
            imageView.centerYAnchor.constraint(equalTo: imageContainerView.centerYAnchor).isActive = true
            imageContainerView.clipsToBounds = true
        }
    }
    
    
    init(users: [SBDUser], frame: CGRect){
        super.init(frame: frame)
        self.setUser(newUsers: users)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func setUser(newUsers: [SBDUser]) {
        self.users = newUsers
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setImage(withCoverUrl coverUrl: String){
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        
        imageStorage.async.object(forKey: coverUrl) { result in
            if case .value(let image) = result {
                
                DispatchQueue.main.async { // Make sure you're on the main thread here
                       
                    imageView.image = image
           
                }
                
            } else {
                
                
             AF.request(coverUrl).responseImage { response in
                    
                    switch response.result {
                    case let .success(value):
                        imageView.image = value
                       
                        try? imageStorage.setObject(value, forKey: coverUrl)
                    case let .failure(error):
                        print(error)
                        imageView.image = UIImage.init(named: "defaultuser")
                    }
                 
                    
                }
                
            }
            
        }
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        stackView.addArrangedSubview(imageView)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        self.addSubview(stackView)
        makeCircularWithSpacing(spacing: 0)
     
    }
    
    
    func setImage(withImage image: UIImage){
        let imageView = UIImageView(image: image)
        
        let stackView = UIStackView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        stackView.addArrangedSubview(imageView)
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        self.addSubview(stackView)
        makeCircularWithSpacing(spacing: 0)
    }
    
}

extension UIImageView {
    
    func beat() {
        
        let pulse = CASpringAnimation(keyPath: "transform.scale")
        pulse.duration = 0.4
        pulse.fromValue = 1.0
        pulse.toValue = 1.12
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        pulse.initialVelocity = 0.5
        pulse.damping = 0.8
        layer.add(pulse, forKey: nil)
    
    
    }
    
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.y")
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        animation.duration = 0.9
        animation.values = [-5.0, 5.0, -5.0, 5.0, -5.0, 2.0, -1.0, 1.0, 0.0 ]
        animation.repeatCount = .infinity
        layer.add(animation, forKey: "shake")
    }
    

    func removeAnimation() {
        
        layer.removeAllAnimations()
        
    }

    func fistBump() {
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1.0
        scaleAnimation.toValue = 1.1
        scaleAnimation.duration = 0.25
        scaleAnimation.autoreverses = true
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)

        layer.add(scaleAnimation, forKey: "fistBump")
    }


    
}
