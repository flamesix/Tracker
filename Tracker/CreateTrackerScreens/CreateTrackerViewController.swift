import UIKit

protocol CreateTrackerViewControllerDelegate: AnyObject {
    func pushCategories() -> [TrackerCategory]
}

final class CreateTrackerViewController: UIViewController {
    
    weak var delegate: CreateTrackerViewControllerDelegate?
    
    private let regularEventButton = TrackerButton(Constants.habit, .trBlack, .trWhite)
    private let unregularEventButton = TrackerButton(Constants.unregularEvent, .trBlack, .trWhite)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func didTapRegularEventButton() {
        let vc = NewTrackerViewController(isRegularEvent: true)
        vc.categories = delegate?.pushCategories() ?? []
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @objc private func didTapUnRegularEventButton() {
        let vc = NewTrackerViewController(isRegularEvent: false)
        vc.categories = delegate?.pushCategories() ?? []
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}


extension CreateTrackerViewController: SettingViewsProtocol {
    func setupView() {
        title = Constants.createTracker
        view.backgroundColor = .trWhite
        view.addSubviews(regularEventButton, unregularEventButton)
        regularEventButton.addTarget(self, action: #selector(didTapRegularEventButton), for: .touchUpInside)
        unregularEventButton.addTarget(self, action: #selector(didTapUnRegularEventButton), for: .touchUpInside)
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            regularEventButton.heightAnchor.constraint(equalToConstant: 60),
            regularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            regularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            regularEventButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            unregularEventButton.topAnchor.constraint(equalTo: regularEventButton.bottomAnchor, constant: 16),
            unregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            unregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            unregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        
        ])
    }
}
