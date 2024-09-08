//
//  CreateTrackerViewController.swift
//  Tracker
//
//  Created by Юрий Гриневич on 27.08.2024.
//

import UIKit

final class CreateTrackerViewController: UIViewController {
    
    private let regularEventButton = TrackerButton("Привычка", .trBlack, .trWhite)
    private let unregularEventButton = TrackerButton("Нерегулярное событие", .trBlack, .trWhite)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func didTapRegularEventButton() {
        let vc = CreateRegularEventViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @objc private func didTapUnRegularEventButton() {
        let vc = CreateUnregularEventViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func setupView() {
        title = "Создание трекера"
        view.backgroundColor = .trWhite
        view.addSubviews(regularEventButton, unregularEventButton)
        regularEventButton.addTarget(self, action: #selector(didTapRegularEventButton), for: .touchUpInside)
        unregularEventButton.addTarget(self, action: #selector(didTapUnRegularEventButton), for: .touchUpInside)
        
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
