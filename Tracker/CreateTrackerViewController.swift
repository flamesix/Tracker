//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Юрий Гриневич on 27.08.2024.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    
    private let regularEventButton: TrackerButton = {
        let button = TrackerButton()
        button.setTitle("Привычка", for: .normal)
        button.addTarget(CreateTrackerViewController.self, action: #selector(didTapRegularEventButton), for: .touchUpInside)
        return button
    }()
    
    private let unregularEventButton: TrackerButton = {
        let button = TrackerButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.addTarget(CreateTrackerViewController.self, action: #selector(didTapUnRegularEventButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

    }
    
    @objc private func didTapRegularEventButton() {
        
    }
    
    @objc private func didTapUnRegularEventButton() {
        
    }
    
    private func setupView() {
        title = "Создание трекера"
        view.backgroundColor = .trWhite
        view.addSubviews(regularEventButton, unregularEventButton)
        
        NSLayoutConstraint.activate([
            regularEventButton.heightAnchor.constraint(equalToConstant: 60),
            regularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            regularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            regularEventButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            unregularEventButton.topAnchor.constraint(equalTo: regularEventButton.bottomAnchor, constant: 16),
            unregularEventButton.heightAnchor.constraint(equalToConstant: 60),
            unregularEventButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            unregularEventButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        
        ])
    }
}
