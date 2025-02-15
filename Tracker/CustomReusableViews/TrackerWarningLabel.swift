import UIKit

final class TrackerWarningLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        text = Constants.warningLabel
        textColor = .trRed
        font = .systemFont(ofSize: 17)
        textAlignment = .center
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
    }
}
