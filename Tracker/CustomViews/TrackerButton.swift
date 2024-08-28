//
//  TrackerButton.swift
//  Tracker
//
//  Created by Юрий Гриневич on 27.08.2024.
//

import UIKit

final class TrackerButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 15
        titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        setTitleColor(.trWhite, for: .normal)
        backgroundColor = .trBlack
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func set(title: String) {
        setTitle(title, for: .normal)
    }
}
