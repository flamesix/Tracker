//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Юрий Гриневич on 09.09.2024.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    
    var isRegularEvent: Bool = true
    
    private let addTrackerNameTextField = TrackerTextField(placeholder: "Введите название трекера")
    private let tableView = TrackerTableView()
    private let createButton = TrackerButton("Создать", .trGray, .trWhite)
    private let cancelButton = TrackerButton("Отменить", .clear, .trRed, 1, .trRed)
    private let buttonStackView = TrackerButtonStackView()
    private let warningLabel = TrackerWarningLabel()
    
    init(isRegularEvent: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.isRegularEvent = isRegularEvent
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHideKeyboardOnTap()
    }
    
    @objc private func didTapCancelButton() {
        dismiss(animated: true)
    }
    
    @objc private func didTapCreateButton() {
        guard let name = addTrackerNameTextField.text, !name.isEmpty else {
            return
        }
    }
    
    private func showScheduleViewController() {
        let vc = ScheduleViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func showCategoryViewController() {
        let vc = CategoryViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func setupView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = isRegularEvent ? .singleLine : .none
        
        addTrackerNameTextField.delegate = self
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        
        title = isRegularEvent ? "Новая привычка" : "Новое нерегулярное событие"
        view.backgroundColor = .trWhite
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        view.addSubviews(addTrackerNameTextField, tableView, buttonStackView)
        setupConstraints()
        
    }
    
    private func setupConstraints() {
        
        if warningLabel.isHidden {
            NSLayoutConstraint.activate([
                addTrackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
                addTrackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                addTrackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                addTrackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
                
                tableView.topAnchor.constraint(equalTo: addTrackerNameTextField.bottomAnchor, constant: 24),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: isRegularEvent ? 150 : 75),
                
                buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                buttonStackView.heightAnchor.constraint(equalToConstant: 60),
                
            ])
        } else {
            NSLayoutConstraint.activate([
                addTrackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
                addTrackerNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                addTrackerNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                addTrackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
                
                warningLabel.topAnchor.constraint(equalTo: addTrackerNameTextField.bottomAnchor, constant: 8),
                warningLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 45),
                warningLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -45),
                warningLabel.heightAnchor.constraint(equalToConstant: 22),
                
                tableView.topAnchor.constraint(equalTo: warningLabel.bottomAnchor, constant: 32),
                tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                tableView.heightAnchor.constraint(equalToConstant: isRegularEvent ? 150 : 75),
                
                buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
                buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
                buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
                buttonStackView.heightAnchor.constraint(equalToConstant: 60),
                
            ])
        }
    }
}

extension NewTrackerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isRegularEvent ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        switch isRegularEvent {
        case true:
            cell.textLabel?.text = indexPath.row == 0 ? "Категория" : "Расписание"
        case false:
            cell.textLabel?.text = "Категория"
        }
        
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = .trBackground
        return cell
    }
}

extension NewTrackerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showCategoryViewController()
        } else if indexPath.row == 1 {
            showScheduleViewController()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        createButton.backgroundColor = .trBlack
        
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
           guard let currentText = textField.text,
                 let stringRange = Range(range, in: currentText) else { return false }

           let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
           return updatedText.count <= 38
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
