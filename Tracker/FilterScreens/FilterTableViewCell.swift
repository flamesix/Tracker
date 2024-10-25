import UIKit

final class FilterTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "FilterTableViewCell"
    
    private lazy var mainLabel: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 17, weight: .regular)
        lable.textColor = .trBlack
        return lable
    }()
    
    private lazy var stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureFilter(filter: String, selectedFilter: String?) {
        if filter == selectedFilter {
            accessoryType = .checkmark
        }
        mainLabel.text = filter
    }
}

extension FilterTableViewCell: SettingViewsProtocol {
    func setupView() {
        selectionStyle = .none
        backgroundColor = .trBackground
        
        contentView.addSubviews(stackView)
        [mainLabel].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            stackView.addArrangedSubview($0)
        }
        
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 75),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16)
        ])
    }
}
