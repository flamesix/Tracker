import UIKit

final class ColorCollectionViewCell: UICollectionViewCell {
    
    static let reuseIdentifier = "ColorCollectionViewCell"
    
    private let colorImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    private let colorBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configure(with color: String) {
        colorImageView.backgroundColor = UIColor(named: color)
    }
    
    public func configureSelection(isSelected: Bool) {
        colorBackgroundView.layer.borderWidth = isSelected ? 3 : 0
        colorBackgroundView.layer.borderColor = colorImageView.backgroundColor?.cgColor
    }
}

extension ColorCollectionViewCell: SettingViewsProtocol {
    func setupView() {
        addSubviews(colorBackgroundView, colorImageView)
        
        addConstraints()
    }
    
    func addConstraints() {
        let padding: CGFloat = 6
        NSLayoutConstraint.activate([
            colorBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            colorBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            colorBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            colorBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            colorImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            colorImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            colorImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding),
            colorImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding),
        ])
    }
}
