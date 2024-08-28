//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Юрий Гриневич on 27.08.2024.
//

import UIKit

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "TrackerCollectionViewCell"
    
    private let backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .green
        imageView.layer.cornerRadius = 16
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let trackerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .trWhite
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .trBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureCell(_ tracker: Tracker) {
        backgroundImageView.backgroundColor = UIColor(named: tracker.color)
        emojiLabel.text = tracker.emoji
        trackerLabel.text = tracker.title
        dateLabel.text = tracker.schedule
        addButton.setImage(UIImage(systemName: "plus"), for: .normal)
        addButton.tintColor = .trWhite
        addButton.backgroundColor = UIColor(named: tracker.color)
    }
    
    private func setupView() {
        contentView.addSubviews(backgroundImageView, emojiLabel, trackerLabel, dateLabel, addButton)
        
        NSLayoutConstraint.activate([
            
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 3 / 5),
            
            emojiLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            
            trackerLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 8),
            trackerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            trackerLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            trackerLabel.bottomAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: -12),
//            trackerLabel.heightAnchor.constraint(equalToConstant: 34),
            
            dateLabel.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            dateLabel.trailingAnchor.constraint(equalTo: addButton.leadingAnchor, constant: -8),
            dateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            
            addButton.widthAnchor.constraint(equalToConstant: 34),
            addButton.heightAnchor.constraint(equalToConstant: 34),
            addButton.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 8),
            addButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
//            addButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            
        ])
    }
}
