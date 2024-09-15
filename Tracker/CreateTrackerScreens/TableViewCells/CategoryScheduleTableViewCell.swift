//
//  CategoryScheduleTableViewCell.swift
//  Tracker
//
//  Created by Юрий Гриневич on 12.09.2024.
//

import UIKit

final class CategoryScheduleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "CategoryScheduleTableViewCell"
    
    private let mainLabel: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 17, weight: .regular)
        lable.textColor = .trBlack
        lable.translatesAutoresizingMaskIntoConstraints = false
        return lable
    }()
    
    private let subLable: UILabel = {
        let lable = UILabel()
        lable.font = .systemFont(ofSize: 17, weight: .regular)
        lable.textColor = .trGray
        lable.translatesAutoresizingMaskIntoConstraints = false
        return lable
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
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
            mainLabel.text = indexPath.row == 0 ? "Категория" : "Расписание"
            subLable.text = indexPath.row == 0 ? category : schedule
        case false:
            mainLabel.text = "Категория"
            subLable.text = category
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
        stackView.addArrangedSubview(mainLabel)
        stackView.addArrangedSubview(subLable)
        
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
