//
//  EmojiCollectionViewCell.swift
//  Tracker
//
//  Created by Юрий Гриневич on 13.09.2024.
//

import UIKit

final class EmojiCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "EmojiCollectionViewCell"
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let emojiBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with emoji: String) {
        emojiLabel.text = emoji
    }
    
    public func configureSelection(isSelected: Bool) {
        emojiBackgroundView.backgroundColor = isSelected ? .trLightGray : .clear
    }
}

extension EmojiCollectionViewCell: SettingViewsProtocol {
    func setupView() {
        addSubviews(emojiBackgroundView, emojiLabel)
        
        addConstraints()
    }
    
    func addConstraints() {
        let verticalPadding: CGFloat = 7
        let horizontalPadding: CGFloat = 10
        
        NSLayoutConstraint.activate([
            emojiBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            emojiBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            emojiBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            emojiBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            emojiLabel.topAnchor.constraint(equalTo: emojiBackgroundView.topAnchor, constant: verticalPadding),
            emojiLabel.bottomAnchor.constraint(equalTo: emojiBackgroundView.bottomAnchor, constant: -verticalPadding),
            emojiLabel.leadingAnchor.constraint(equalTo: emojiBackgroundView.leadingAnchor, constant: horizontalPadding),
            emojiLabel.trailingAnchor.constraint(equalTo: emojiBackgroundView.trailingAnchor, constant: -horizontalPadding)
        
        ])
    }
}
