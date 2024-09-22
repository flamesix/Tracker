//
//  TrackerCollectionViewCell.swift
//  Tracker
//
//  Created by Юрий Гриневич on 27.08.2024.
//

import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func isNotFutureDate() -> Bool
    func didTapCompletedButton(for cell: TrackerCollectionViewCell)
    func didTapCompletedButton(_ id: UUID, _ isButtonTapped: Bool)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: TrackerCollectionViewCellDelegate?
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
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.backgroundColor = .trEmojiBackground
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
    
    private let counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .trBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completeTrackerButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private var isButtonTapped = false
    private var dayCounter = 0
    var id: UUID = UUID() 
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        completeTrackerButton.alpha = 1
    }
    
    // TODO: Склонение дней
    //Локализацию пока не добавляю, будет дальше по курсу
    @objc private func didTapCompleteTrackerButton() {
        if delegate?.isNotFutureDate() ?? false {
            isButtonTapped = !isButtonTapped
            delegate?.didTapCompletedButton(id, isButtonTapped)
            if isButtonTapped {
                completeTrackerButton.setImage(UIImage(named: "doneButton"), for: .normal)
                completeTrackerButton.alpha = 0.3
                dayCounter += 1
                counterLabel.text = "\(dayCounter) день"
                
                delegate?.didTapCompletedButton(for: self)
            } else {
                completeTrackerButton.setImage(UIImage(systemName: "plus"), for: .normal)
                completeTrackerButton.alpha = 1
                dayCounter -= 1
                counterLabel.text = "\(dayCounter) день"
            }
        }
    }
    
    public func configureCell(_ tracker: Tracker, weekDay: Int, completedTrackers: [TrackerRecord]) {
            backgroundImageView.backgroundColor = UIColor(named: tracker.color)
            emojiLabel.text = tracker.emoji
            trackerLabel.text = tracker.title
            // TODO: Склонение дней
            counterLabel.text = "\(completedTrackers.filter({$0.id == tracker.id}).count) дней"
            completeTrackerButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeTrackerButton.tintColor = .trWhite
            completeTrackerButton.backgroundColor = UIColor(named: tracker.color)
    }
}

extension TrackerCollectionViewCell: SettingViewsProtocol {
    func setupView() {
        completeTrackerButton.addTarget(self, action: #selector(didTapCompleteTrackerButton), for: .touchUpInside)
        contentView.addSubviews(backgroundImageView, emojiLabel, trackerLabel, counterLabel, completeTrackerButton)
        addConstraints()
        
    }
    
    func addConstraints() {
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
            
            counterLabel.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 16),
            counterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(equalTo: completeTrackerButton.leadingAnchor, constant: -8),
            counterLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -24),
            
            completeTrackerButton.widthAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.heightAnchor.constraint(equalToConstant: 34),
            completeTrackerButton.topAnchor.constraint(equalTo: backgroundImageView.bottomAnchor, constant: 8),
            completeTrackerButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            
        ])
    }
}
