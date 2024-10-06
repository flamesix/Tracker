import UIKit

final class CategoryScheduleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CategoryScheduleTableViewCell"
    
    private let mainLabel: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 17, weight: .regular)
        lable.textColor = .trBlack
        return lable
    }()
    
    private let subLabel: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 17, weight: .regular)
        lable.textColor = .trGray
        return lable
    }()
    
    private let stackView: UIStackView = {
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
    
    public func configure(isRegularEvent: Bool, indexPath: IndexPath, schedule: String, category: String) {
        switch isRegularEvent {
        case true:
            mainLabel.text = indexPath.row == 0 ? Constants.category : Constants.schedule
            subLabel.text = indexPath.row == 0 ? category : schedule
        case false:
            mainLabel.text = Constants.category
            subLabel.text = category
        }
    }
    
    public func configureCategory(category: String, selectedCategory: String) {
        if category == selectedCategory {
            accessoryType = .checkmark
        }
        mainLabel.text = category
    }
}

extension CategoryScheduleTableViewCell: SettingViewsProtocol {
    func setupView() {
        selectionStyle = .none
        backgroundColor = .trBackground
        
        contentView.addSubviews(stackView)
        [mainLabel, subLabel].forEach {
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
