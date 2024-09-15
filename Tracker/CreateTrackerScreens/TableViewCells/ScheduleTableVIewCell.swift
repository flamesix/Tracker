//
//  ScheduleTableVIewCell.swift
//  Tracker
//
//  Created by Юрий Гриневич on 13.09.2024.
//

import UIKit

final class ScheduleTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "ScheduleTableViewCell"
    
    public let switcher: UISwitch = {
        let switchControl = UISwitch()
        switchControl.onTintColor = .trBlue
        return switchControl
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func config(with day: String, schedule: [Int], indexPath: IndexPath) {
        textLabel?.text = day
        switcher.tag = indexPath.row
        
        var onSwitch = Set<Int>()
        for index in schedule {
            if index != 1 {
                onSwitch.insert(index - 2)
            } else {
                onSwitch.insert(6)
            }
        }

        onSwitch.forEach { index in
            if index == indexPath.row {
                switcher.isOn = true
            }
        }
    }
}

extension ScheduleTableViewCell: SettingViewsProtocol {
    func setupView() {
        selectionStyle = .none
        backgroundColor = .trBackground
        contentView.addSubviews(switcher)
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(equalToConstant: 75),
            switcher.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            switcher.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
}
