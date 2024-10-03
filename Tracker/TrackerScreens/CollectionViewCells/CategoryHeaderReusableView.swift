import UIKit

final class CategoryHeaderReusableView: UICollectionReusableView {
    
    static let reuseIdentifier = "CategoryHeaderReusableView"
    
    private let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .bold)
        label.textColor = .trBlack
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    public func configure(with category: TrackerCategory) {
        categoryTitleLabel.text = category.title
    }
    
    public func configure(with title: String) {
        categoryTitleLabel.text = title
    }
}

extension CategoryHeaderReusableView: SettingViewsProtocol {
    func setupView() {
        addSubviews(categoryTitleLabel)
        addConstraints()
        
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            categoryTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            categoryTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            categoryTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
