//
//  PromoteDetailVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/19/23.
//

import UIKit
import SafariServices

class PromoteDetailVC: UIViewController {
    
    var promote: PromoteModel!
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let imageView = UIImageView()
    let claimButton = UIButton(type: .system)
    let readMoreButton = UIButton(type: .system)
    let activeStatusView = ActiveStatusView()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        setupView()
        populateView()
    }
    
    private func setupView() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        
        imageView.contentMode = .scaleAspectFit
        imageView.frame.size = CGSize(width: self.view.bounds.width, height: 250)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10.0
        
        claimButton.setTitle("Claim Reward", for: .normal)
        claimButton.addTarget(self, action: #selector(claimReward), for: .touchUpInside)
        claimButton.setTitleColor(.black, for: .normal)
        claimButton.backgroundColor = .systemBlue
        claimButton.layer.cornerRadius = 10.0
        
        readMoreButton.setTitle("Read More", for: .normal)
        readMoreButton.addTarget(self, action: #selector(readMore), for: .touchUpInside)
        readMoreButton.setTitleColor(.black, for: .normal)
        readMoreButton.backgroundColor = .systemGreen
        readMoreButton.layer.cornerRadius = 10.0
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, activeStatusView, imageView, descriptionLabel, claimButton, readMoreButton])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    private func populateView() {
        titleLabel.text = promote.name
        descriptionLabel.text = promote.description
        activeStatusView.setActive(promote.isActive)
        imageView.load(url: promote.imageUrl, str: promote.imageUrl.absoluteString)
    }

    
    @objc func claimReward() {
        // Logic for claiming reward
    }
    
    @objc func readMore() {
        if let url = URL(string: "http://your-website.com") {
            let safariVC = SFSafariViewController(url: url)
            present(safariVC, animated: true, completion: nil)
        }
    }
}

class ActiveStatusView: UIView {
    private let statusLabel = UILabel()
    
    init() {
        super.init(frame: .zero)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        layer.cornerRadius = 10
        addSubview(statusLabel)
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            statusLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func setActive(_ isActive: Bool) {
        backgroundColor = isActive ? .green : .red
        statusLabel.text = isActive ? "Active" : "Inactive"
    }
}

