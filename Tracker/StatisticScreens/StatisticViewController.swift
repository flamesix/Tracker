import UIKit

final class StatisticViewController: UIViewController {
    
    private let emptyLogo = TrackerEmptyLogo("EmptyLogoStat")
    private let emptyLabel = TrackerEmptyLabel("Анализировать пока нечего")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    
}

extension StatisticViewController: SettingViewsProtocol {
    func setupView() {
        title = "Статистика"
        
        view.backgroundColor = .trWhite
        view.addSubviews(emptyLogo, emptyLabel)
        addConstraints()
        
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
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
