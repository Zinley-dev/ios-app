//
//  ChatCell.swift
//  Stitchbox
//
//  Created by Khoi Nguyen on 4/14/23.
//
import UIKit

class ChatCell: UITableViewCell {
    
    let avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 17
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayout() {
        addSubview(avatarImageView)

        NSLayoutConstraint.activate([
            avatarImageView.heightAnchor.constraint(equalToConstant: 34),
            avatarImageView.widthAnchor.constraint(equalToConstant: 34),
            avatarImageView.topAnchor.constraint(equalTo: topAnchor, constant: 4)
        ])

        textLabel?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel!.topAnchor.constraint(equalTo: topAnchor, constant: 4),
            textLabel!.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])

        // Add minimum height constraint
        heightAnchor.constraint(greaterThanOrEqualToConstant: 56).isActive = true
    }


}

