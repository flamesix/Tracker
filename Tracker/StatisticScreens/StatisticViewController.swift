import UIKit

final class StatisticViewController: UIViewController {
    
    private lazy var emptyLogo = TrackerEmptyLogo("EmptyLogoStat")
    private lazy var emptyLabel = TrackerEmptyLabel(Constants.nothingToAnalyze)
    
    private lazy var completedTrackers = TrackerStatisticBlockView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateEmptyState()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateEmptyState()
    }
    
    private func updateEmptyState() {
        let completedTrackersCount = StatisticStorage.shared.completedCount
        if completedTrackersCount != 0 {
            emptyLogo.isHidden = true
            emptyLabel.isHidden = true
            completedTrackers.isHidden = false
            let completedTrackersString = String.localizedStringWithFormat(
                NSLocalizedString("numberOfCompletedTrackers", comment: "Number of completed trackers"),
                completedTrackersCount
            )
            completedTrackers.configStatistic(completedTrackersCount, completedTrackersString)
        } else {
            emptyLogo.isHidden = false
            emptyLabel.isHidden = false
            completedTrackers.isHidden = true
        }
    }
}

extension StatisticViewController: SettingViewsProtocol {
    func setupView() {
        title = Constants.statistic
        
        view.backgroundColor = .trWhite
        view.addSubviews(emptyLogo, emptyLabel, completedTrackers)
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            completedTrackers.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            completedTrackers.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            completedTrackers.heightAnchor.constraint(equalToConstant: 90),
            completedTrackers.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            
            emptyLogo.widthAnchor.constraint(equalToConstant: 80),
            emptyLogo.heightAnchor.constraint(equalToConstant: 80),
            emptyLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyLogo.bottomAnchor, constant: 8),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyLabel.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
}
