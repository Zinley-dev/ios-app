//
//  PromoteDetailVC.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 5/19/23.
//

import UIKit
import SafariServices


class PromoteDetailVC: UIViewController, UIScrollViewDelegate {
    
    var promote: PromoteModel!
    
    private let fireworkController = FountainFireworkController()
    private let fireworkController2 = ClassicFireworkController()
    
    let backButton: UIButton = UIButton(type: .custom)
    
    let scrollView = UIScrollView()
    let contentView = UIView()
    
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let imageView = UIImageView()
    let statusLabel = UILabel()
    let datesLabel = UILabel()
    let maxMembersLabel = UILabel()
    
    let claimButton = UIButton(type: .system)
    let readMoreButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .background
        setupButtons()
        setupView()
        populateView()
    }
    
    private func setupView() {
        scrollView.delegate = self
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0
        
        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .white
        descriptionLabel.numberOfLines = 0
        
        statusLabel.font = UIFont.boldSystemFont(ofSize: 16)
        statusLabel.textColor = .green
        
        datesLabel.font = UIFont.systemFont(ofSize: 14)
        datesLabel.textColor = .white
        
        maxMembersLabel.font = UIFont.systemFont(ofSize: 14)
        maxMembersLabel.textColor = .white
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        claimButton.setTitle("Claim Reward", for: .normal)
        claimButton.addTarget(self, action: #selector(claimReward), for: .touchUpInside)
        claimButton.setTitleColor(.black, for: .normal)
        //claimButton.backgroundColor = .secondary
        claimButton.layer.cornerRadius = 10
        claimButton.clipsToBounds = true
                
        readMoreButton.setTitle("Read More", for: .normal)
        readMoreButton.addTarget(self, action: #selector(readMore), for: .touchUpInside)
        readMoreButton.setTitleColor(.black, for: .normal)
        readMoreButton.backgroundColor = .tertiary
        readMoreButton.layer.cornerRadius = 10
        readMoreButton.clipsToBounds = true
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, imageView, statusLabel, datesLabel, maxMembersLabel, descriptionLabel, claimButton, readMoreButton])
        stackView.axis = .vertical
        stackView.spacing = 16
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
            
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func populateView() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none

        titleLabel.text = promote.name
        imageView.load(url: promote.imageUrl, str: promote.imageUrl.absoluteString)
        

        claimButton.isEnabled = promote.isActive
        claimButton.backgroundColor = promote.isActive ? .systemGreen : .systemGray
        
        let boldAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 16)
        ]

        let descriptionText = "Description: \(promote.description)"
        let attributedDescriptionText = NSMutableAttributedString(string: descriptionText)
        attributedDescriptionText.addAttributes(boldAttributes, range: NSRange(location: 0, length: 12)) // Assuming "Description:" has 12 characters

        descriptionLabel.attributedText = attributedDescriptionText
        
        statusLabel.text = "Status: " + (promote.isActive ? "Active" : "Inactive")
        let attributedStatusLabel = NSMutableAttributedString(string: statusLabel.text!)
        attributedStatusLabel.addAttributes(boldAttributes, range: NSRange(location: 0, length: 7)) // Assuming "Status:" has 7 characters
        statusLabel.attributedText = attributedStatusLabel

        datesLabel.text = "Start Date: \(dateFormatter.string(from: promote.startDate)) - End Date: \(dateFormatter.string(from: promote.endDate))"
        let attributedDatesLabel = NSMutableAttributedString(string: datesLabel.text!)
        attributedDatesLabel.addAttributes(boldAttributes, range: NSRange(location: 0, length: 11)) // Assuming "Start Date:" has 11 characters
        datesLabel.attributedText = attributedDatesLabel

        maxMembersLabel.text = "Max Members: \(promote.maxMember)"
        let attributedMaxMembersLabel = NSMutableAttributedString(string: maxMembersLabel.text!)
        attributedMaxMembersLabel.addAttributes(boldAttributes, range: NSRange(location: 0, length: 12)) // Assuming "Max Members:" has 12 characters
        maxMembersLabel.attributedText = attributedMaxMembersLabel

    }

    
    @objc func claimReward() {
        // Logic for claiming reward
        
            presentSwiftLoader()
        
            APIManager().applyPromotion(id: promote.id) { result in
                switch result {
                case .success(let apiResponse):
                    
                    print(apiResponse)
                    
                    Dispatch.main.async {
                        SwiftLoader.hide()
                        self.fireWorkAnimation()
                    }
                    
                case .failure(let error):
                    print(error)
                    
                    Dispatch.main.async {
                        SwiftLoader.hide()
                        self.showErrorAlert("Oops!", msg: "Claim unsuccessful. Please check promotion details or ensure all requirements have been met")
                        
                    }
                    
            }
        }
        
    }
    
    func fireWorkAnimation() {
        
        // Update pass eligible
        reloadGlobalUserInformation()
        
        claimButton.isEnabled = false
        claimButton.backgroundColor = .darkGray
        claimButton.setTitle("Reward claimed", for: .normal)
        claimButton.setTitleColor(.white, for: .normal)
        
        self.fireworkController.addFirework(sparks: 10, above: self.claimButton)
        self.fireworkController2.addFireworks(count: 10, sparks: 8, around: self.claimButton)
        showNote(text: "Congratulations! Your claim was successful. Enjoy your reward!")
        
    }
    
    @objc func readMore() {
        let safariVC = SFSafariViewController(url: promote.originalLink)
        present(safariVC, animated: true, completion: nil)
    }
}



extension PromoteDetailVC {
    
    func setupButtons() {
        
        setupBackButton()
    
    }
    
    
    func setupBackButton() {
    
        backButton.frame = back_frame
        backButton.contentMode = .center

        if let backImage = UIImage(named: "back_icn_white") {
            let imageSize = CGSize(width: 13, height: 23)
            let padding = UIEdgeInsets(top: (back_frame.height - imageSize.height) / 2,
                                       left: (back_frame.width - imageSize.width) / 2 - horizontalPadding,
                                       bottom: (back_frame.height - imageSize.height) / 2,
                                       right: (back_frame.width - imageSize.width) / 2 + horizontalPadding)
            backButton.imageEdgeInsets = padding
            backButton.setImage(backImage, for: [])
        }

        backButton.addTarget(self, action: #selector(onClickBack(_:)), for: .touchUpInside)
        backButton.setTitleColor(UIColor.white, for: .normal)
        backButton.setTitle("", for: .normal)
        let backButtonBarButton = UIBarButtonItem(customView: backButton)
        navigationItem.title = "SB Promotion"

        self.navigationItem.leftBarButtonItem = backButtonBarButton


        
    }

    
    func showErrorAlert(_ title: String, msg: String) {
                                                                                                                                           
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }

    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0 {
           navigationController?.setNavigationBarHidden(true, animated: true)
            
             self.tabBarController?.tabBar.isTranslucent = true
            
            

        } else {
           navigationController?.setNavigationBarHidden(false, animated: true)

            self.tabBarController?.tabBar.isTranslucent = false
           
        }
       
    }
    
}


extension PromoteDetailVC {
    
    @objc func onClickBack(_ sender: AnyObject) {
        if let navigationController = self.navigationController {
            navigationController.popViewController(animated: true)
        }
    }
    
}
