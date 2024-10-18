import UIKit

final class TrackerStatisticBlockView: UIView {
    private let view: UIView = {
        let view = UIView()
        return view
    }()
    
    private let numberTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .trBlack
        return label
    }()
    
    private let subTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .trBlack
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientBorder(width: 1, colors: [.trGradient3, .trGradient2, .trGradient1], andRoundCornersWithRadius: 16)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configStatistic(_ numberTitle: Int, _ subTitle: String) {
        self.numberTitle.text = String(numberTitle)
        self.subTitle.text = subTitle
    }
}

extension TrackerStatisticBlockView: SettingViewsProtocol {
    func setupView() {
        addSubviews(view)
        view.addSubviews(numberTitle, subTitle)
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
            
            numberTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            numberTitle.topAnchor.constraint(equalTo: view.topAnchor),
            numberTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            numberTitle.heightAnchor.constraint(equalToConstant: 41),
            
            subTitle.topAnchor.constraint(equalTo: numberTitle.bottomAnchor, constant: 7),
            subTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            subTitle.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            subTitle.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            subTitle.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
}
