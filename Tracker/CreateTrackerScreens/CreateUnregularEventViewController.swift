//
//  CreateUnregularEventViewController.swift
//  Tracker
//
//  Created by Юрий Гриневич on 28.08.2024.
//

import UIKit

final class CreateUnregularEventViewController: UIViewController {
    
    private let addTrackerNameTextField = TrackerTextField(placeholder: "Введите название трекера")
    private let tableView = TrackerTableView()
    private let createButton = TrackerButton("Создать", .trGray, .trWhite)
    private let cancelButton = TrackerButton("Отменить", .clear, .trRed, 1, .trRed)
    private let buttonStackView = TrackerButtonStackView()
    private let warningLabel = TrackerWarningLabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let name = addTrackerNameTextField.text, !name.isEmpty else {
            return
        }
    }
    
    private func showCategoryViewController() {
        let vc = CategoryViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func setupView() {
        tableView.dataSource = self
        tableView.delegate = self
        
        addTrackerNameTextField.delegate = self
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        
        title = "Новое нерегулярное событие"
        view.backgroundColor = .trWhite
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        view.addSubviews(addTrackerNameTextField, tableView, buttonStackView)
        
        NSLayoutConstraint.activate([
            addTrackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            addTrackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addTrackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addTrackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: addTrackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}

extension CreateUnregularEventViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = "Категория"
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .trBackground
        return cell
    }
}

extension CreateUnregularEventViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showCategoryViewController()
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension CreateUnregularEventViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
            createButton.backgroundColor = .trBlack

    }
}
