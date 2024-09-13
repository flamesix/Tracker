//
//  TrackerTextField.swift
//  Tracker
//
//  Created by Юрий Гриневич on 28.08.2024.
//

import UIKit

final class TrackerTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    convenience init(placeholder: String) {
        self.init(frame: .zero)
        set(placeholderText: placeholder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        layer.cornerRadius = 16
        clearButtonMode = .whileEditing
        addPadding(.left(16))
        font = .systemFont(ofSize: 17, weight: .regular)
        backgroundColor = .trBackground
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    public func set(placeholderText: String) {
        placeholder = placeholderText
    }
}


