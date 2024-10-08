import UIKit

final class TrackerButtonStackView: UIStackView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        axis = .horizontal
        distribution = .fillEqually
        spacing = 8
        translatesAutoresizingMaskIntoConstraints = false
    }
}
