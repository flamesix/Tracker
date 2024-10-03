import UIKit

final class TrackerEmptyLogo: UIImageView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init(_ imageName: String) {
        self.init(frame: .zero)
        image = UIImage(named: imageName)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        image = UIImage(named: "EmptyLogo")
        translatesAutoresizingMaskIntoConstraints = false
    }
}
