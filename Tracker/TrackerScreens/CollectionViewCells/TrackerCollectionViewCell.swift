import UIKit

protocol TrackerCollectionViewCellDelegate: AnyObject {
    func isNotFutureDate() -> Bool
    func didTapCompletedButton(for cell: TrackerCollectionViewCell, isButtonTapped: Bool)
}

final class TrackerCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: TrackerCollectionViewCellDelegate?
    static let reuseIdentifier = "TrackerCollectionViewCell"
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .green
        imageView.layer.cornerRadius = 16
        return imageView
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.backgroundColor = .trEmojiBackground
        label.textAlignment = .left
        return label
    }()
    
    private lazy var trackerLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .trWhite
        label.overrideUserInterfaceStyle = .light
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .trBlack
        return label
    }()
    
    private lazy var completeTrackerButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 17
        return button
    }()
    
    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "pin")
        imageView.tintColor = .trWhite
        imageView.overrideUserInterfaceStyle = .light
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private var isButtonTapped = false
    private var isPinned = false
    private var dayCounter = 0
    private var id: UUID = UUID()
    
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
    
    func updateID(id: UUID) {
        self.id = id
    }
    
    @objc private func didTapCompleteTrackerButton() {
        if delegate?.isNotFutureDate() ?? false {
            isButtonTapped = !isButtonTapped
            if isButtonTapped {
                updateCompleteTrackerButtonState(isButtonTapped: isButtonTapped)
                updateDayCounter(day: dayCounter + 1)
                delegate?.didTapCompletedButton(for: self, isButtonTapped: isButtonTapped)
            } else {
                updateCompleteTrackerButtonState(isButtonTapped: isButtonTapped)
                updateDayCounter(day: dayCounter - 1)
                delegate?.didTapCompletedButton(for: self, isButtonTapped: isButtonTapped)
            }
        }
    }
    
    private func updateCompleteTrackerButtonState(isButtonTapped: Bool) {
        isButtonTapped ? completeTrackerButton.setImage(UIImage(named: "doneButton"), for: .normal) : completeTrackerButton.setImage(UIImage(systemName: "plus"), for: .normal)
        completeTrackerButton.alpha = isButtonTapped ? 0.3 : 1
    }
    
    private func updateDayCounter(day: Int) {
        dayCounter = day
        
        let dayString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of days completed"),
            day
        )
        counterLabel.text = dayString
    }
    
    private func configureCompleteTrackerButtonState(_ tracker: Tracker, date: Date, completedTrackers: [TrackerRecord]) {
        if completedTrackers.contains(where: { $0.id == tracker.id && Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day) }) {
            completeTrackerButton.setImage(UIImage(named: "doneButton"), for: .normal)
            completeTrackerButton.alpha = 0.3
            isButtonTapped = true
        } else {
            completeTrackerButton.setImage(UIImage(systemName: "plus"), for: .normal)
            completeTrackerButton.alpha = 1
            isButtonTapped = false
        }
    }
    
    public func configureCell(_ tracker: Tracker, weekDay: Int, date: Date, completedTrackers: [TrackerRecord]) {
        backgroundImageView.backgroundColor = UIColor(named: tracker.color)
        emojiLabel.text = tracker.emoji
        trackerLabel.text = tracker.title
        updateDayCounter(day: completedTrackers.filter({$0.id == tracker.id}).count)
        pinImageView.isHidden = !tracker.isPinned
        configureCompleteTrackerButtonState(tracker, date: date, completedTrackers: completedTrackers)
        completeTrackerButton.tintColor = .trWhite
        completeTrackerButton.backgroundColor = UIColor(named: tracker.color)
    }
}

extension TrackerCollectionViewCell: SettingViewsProtocol {
    func setupView() {
        completeTrackerButton.addTarget(self, action: #selector(didTapCompleteTrackerButton), for: .touchUpInside)
        contentView.addSubviews(backgroundImageView, emojiLabel, trackerLabel, counterLabel, completeTrackerButton, pinImageView)
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
            
            pinImageView.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            pinImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            pinImageView.heightAnchor.constraint(equalToConstant: 24),
            pinImageView.widthAnchor.constraint(equalToConstant: 24),
            
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
