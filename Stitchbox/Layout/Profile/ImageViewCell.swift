//
//  ImageViewCell.swift
//  CompositionalDiffablePlayground
//
//  Created by Filip Němeček on 16/01/2021.
//

import UIKit

class ImageViewCell: UICollectionViewCell {
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    private lazy var videoSignView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "play")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        // Add shadow to layer
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOpacity = 0.5
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowRadius = 2
        
        return imageView
    }()

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func configure(with image: UIImage) {
        imageView.image = image
        videoSignView.isHidden = true
    }
    
    func configureWithFit(with image: UIImage) {
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        videoSignView.isHidden = true
    }
  
    func configureWithUrl(with data: PostModel) {
   
        self.imageView.load(url: data.imageUrl, str: data.imageUrl.absoluteString)
        
        if !data.muxPlaybackId.isEmpty {
            
            videoSignView.isHidden = false
            
        } else {
            
            videoSignView.isHidden = true
            
        }
      
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: imageView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),
        ])
        
        contentView.addSubview(videoSignView)
        
        NSLayoutConstraint.activate([
           
            videoSignView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            videoSignView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            videoSignView.widthAnchor.constraint(equalToConstant: 25),
            videoSignView.heightAnchor.constraint(equalToConstant: 25)
           
        ])
        
    }
    
}
