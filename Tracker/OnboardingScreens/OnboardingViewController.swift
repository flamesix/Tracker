import UIKit

final class OnboardingViewController: UIViewController {
    
    private var backgroundImageTitle: String
    private var onboardLabelText: String
    
    private let onboardButton = TrackerButton(Constants.wowTechs, .trBlack, .trWhite)
    
    private lazy var onboardLabel: UILabel = {
        let label = UILabel()
        label.text = onboardLabelText
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .trBlack
        return label
    }()
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: backgroundImageTitle))
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    init(backgroundImageTitle: String, onboardLabelText: String) {
        self.backgroundImageTitle = backgroundImageTitle
        self.onboardLabelText = onboardLabelText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func didTapOnboardButton() {
        OnboardingStateStorage.shared.isShowed = true
        dismiss(animated: true)
    }
}

extension OnboardingViewController: SettingViewsProtocol {
    func setupView() {
        view.addSubviews(backgroundImageView, onboardButton, onboardLabel)
        addConstraints()
        onboardButton.addTarget(self, action: #selector(didTapOnboardButton), for: .touchUpInside)
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            onboardButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            onboardButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            onboardButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            onboardButton.heightAnchor.constraint(equalToConstant: 60),
            
            onboardLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            onboardLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            onboardLabel.bottomAnchor.constraint(equalTo: onboardButton.topAnchor, constant: -190),
            onboardLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
        ])
    }
}
