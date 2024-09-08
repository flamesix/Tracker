//
//  CategoryHeaderReusableView.swift
//  Tracker
//
//  Created by Юрий Гриневич on 27.08.2024.
//

import UIKit

final class CategoryHeaderReusableView: UICollectionReusableView {
    
    private let categoryTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .trBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(categoryTitleLabel)
        
        NSLayoutConstraint.activate([
            categoryTitleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryTitleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            categoryTitleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
