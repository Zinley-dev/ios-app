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
    
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.numberOfLines = 1
        label.textColor = .white
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.numberOfLines = 1
        label.textColor = .white
        label.backgroundColor = .black
        label.text = "10 Stiches"
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }()



    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.layer.shadowColor = UIColor.black.cgColor
        stackView.layer.shadowOpacity = 0.5
        stackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        stackView.layer.shadowRadius = 2
        stackView.clipsToBounds = false
        stackView.layer.masksToBounds = false
        return stackView
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
   
        self.imageView.loadProfileContent(url: data.imageUrl, str: data.imageUrl.absoluteString)
        
        if !data.muxPlaybackId.isEmpty {
            
            stackView.isHidden = false
            countView(with: data)
            
        } else {
            
            stackView.isHidden = true
            countLabel.text = ""
            
        }
      
    }
    
    private func setupView() {
        contentView.addSubview(imageView)
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true

        // Add gradient overlay
        let gradient = CAGradientLayer()
        gradient.frame = imageView.bounds
        gradient.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradient.locations = [0.5, 1.0]
        imageView.layer.insertSublayer(gradient, at: 0)

        contentView.addSubview(stackView)

        contentView.addSubview(infoLabel)

        stackView.addArrangedSubview(videoSignView)
        videoSignView.layer.cornerRadius = 10
        videoSignView.layer.masksToBounds = true

        stackView.addArrangedSubview(countLabel)

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: imageView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            // Size constraints for videoSignView
            videoSignView.widthAnchor.constraint(equalToConstant: 30),
            videoSignView.heightAnchor.constraint(equalToConstant: 30),

            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            infoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),

            
        ])
    }


    func reset() {
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    func countView(with data: PostModel) {
        
        APIManager.shared.getPostStats(postId: data.id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let apiResponse):

                guard let dataDictionary = apiResponse.body?["data"] as? [String: Any] else {
                    print("Couldn't cast")
                    return
                }
            
                do {
                    let data = try JSONSerialization.data(withJSONObject: dataDictionary, options: .fragmentsAllowed)
                    let decoder = JSONDecoder()
                    let stats = try decoder.decode(Stats.self, from: data)
                    DispatchQueue.main.async {
                        self.countLabel.text = "\(stats.view.total)"
                    }
                } catch {
                    print("Error decoding JSON: \(error)")
                }
            case .failure(let error):
                print(error)
            }
        }
        
    }



}
