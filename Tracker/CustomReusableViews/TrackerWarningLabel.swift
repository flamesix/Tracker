//
//  TrackerWarningLabel.swift
//  Tracker
//
//  Created by Юрий Гриневич on 08.09.2024.
//

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
        text = "Ограничение 38 символов"
        textColor = .trRed
        font = .systemFont(ofSize: 17)
        textAlignment = .center
        isHidden = true
        translatesAutoresizingMaskIntoConstraints = false
    }
}
