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
        label.font = FontManager.shared.roboto(.Regular, size: 10)
        label.numberOfLines = 1
        label.textColor = .white
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var stitchCountLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = FontManager.shared.roboto(.Regular, size: 10)
        label.numberOfLines = 1
        label.textColor = .white
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return label
    }()
    
    private lazy var stitchSignView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "partner white")
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
    
    
    
    lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.numberOfLines = 1
        label.textColor = .white
        label.backgroundColor = .black
        label.text = ""
        label.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        label.layer.cornerRadius = 3
        label.clipsToBounds = true
        return label
    }()



    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 2
        stackView.layer.shadowColor = UIColor.black.cgColor
        stackView.layer.shadowOpacity = 0.5
        stackView.layer.shadowOffset = CGSize(width: 0, height: 2)
        stackView.layer.shadowRadius = 2
        stackView.clipsToBounds = false
        stackView.layer.masksToBounds = false
        return stackView
    }()
    
    private lazy var stitchStackView: UIStackView = {
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


    var viewCount: Int?
    var stitchViewCount: Int?

    
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
        stitchSignView.isHidden = true
    }
    
    func configureWithFit(with image: UIImage) {
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        videoSignView.isHidden = true
        stitchSignView.isHidden = true
    }
  
    func configureWithUrl(with data: PostModel) {
        
        if self.imageView.image == nil {
            self.imageView.loadProfileContent(url: data.imageUrl, str: data.imageUrl.absoluteString)
        }
 
        if !data.muxPlaybackId.isEmpty {
            
            stackView.isHidden = false
            stitchStackView.isHidden = false
            countView(with: data)
            countViewStitch(with: data)
        } else {
            
            stackView.isHidden = true
            stitchStackView.isHidden = true
            countLabel.text = ""
            stitchCountLabel.text = ""
            
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
        contentView.addSubview(stitchStackView)
        contentView.addSubview(infoLabel)

        stackView.addArrangedSubview(videoSignView)
        videoSignView.layer.cornerRadius = 10
        videoSignView.layer.masksToBounds = true

        stackView.addArrangedSubview(countLabel)

        stitchStackView.addArrangedSubview(stitchSignView)
        stitchSignView.layer.cornerRadius = 10
        stitchSignView.layer.masksToBounds = true

        stitchStackView.addArrangedSubview(stitchCountLabel)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: imageView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: imageView.bottomAnchor),

            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            // Pin stitchStackView to the right side of the container
            stitchStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
            stitchStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),

            // Size constraints for videoSignView
            videoSignView.widthAnchor.constraint(equalToConstant: 20),
            videoSignView.heightAnchor.constraint(equalToConstant: 20),
            
            stitchSignView.widthAnchor.constraint(equalToConstant: 20),
            stitchSignView.heightAnchor.constraint(equalToConstant: 20),

            infoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            infoLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            infoLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -4),
        ])


    }


    func reset() {
        self.layer.borderColor = UIColor.clear.cgColor
    }
    
    func countView(with data: PostModel) {
        
        if viewCount == nil {
            
            APIManager.shared.getPostStats(postId: data.id) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):

                    guard let dataDictionary = apiResponse.body?["data"] as? [String: Any] else {
                        print("Couldn't cast")
                        self.viewCount = 0
                        return
                    }
                
                    do {
                        let data = try JSONSerialization.data(withJSONObject: dataDictionary, options: .fragmentsAllowed)
                        let decoder = JSONDecoder()
                        let stats = try decoder.decode(Stats.self, from: data)
                        DispatchQueue.main.async {
                            self.viewCount = stats.view.total
                            self.countLabel.text = "\(formatPoints(num: Double(stats.view.total)))"
                        }
                    } catch {
                        print("Error decoding JSON: \(error)")
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        } else {
            self.viewCount = 0
        }
        
    }

    
    
    func countViewStitch(with data: PostModel) {
        
        if stitchViewCount == nil {
            
            APIManager.shared.countPostStitch(pid: data.id) { [weak self] result in
                guard let self = self else { return }

                switch result {
                case .success(let apiResponse):
                    print(apiResponse)

                    guard let total = apiResponse.body?["total"] as? Int else {
                        print("Couldn't find the 'total' key")
                        DispatchQueue.main.async {
                            self.viewCount = 0
                            self.stitchCountLabel.text = "0"
                        }
                        return
                    }

                    DispatchQueue.main.async {
                        self.viewCount = total
                        self.stitchCountLabel.text = "\(formatPoints(num: Double(total)))"
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        self.viewCount = 0
                        self.stitchCountLabel.text = "0"
                    }
                    print(error)
                }
            }

        
        } else {
            self.stitchViewCount = 0
        }
        
    }


}
