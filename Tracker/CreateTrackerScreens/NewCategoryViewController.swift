//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Юрий Гриневич on 12.09.2024.
//

import UIKit

protocol NewCategoryViewControllerDelegate: AnyObject {
    func updateTable()
}

final class NewCategoryViewController: UIViewController {

    weak var delegate: NewCategoryViewControllerDelegate?
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    private let categoryTitleTextField = TrackerTextField(placeholder: "Введите название категории")
    private let doneButton = TrackerButton("Готово", .trGray, .trWhite)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupHideKeyboardOnTap()
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        if let text = textField.text, !text.isEmpty {
            doneButton.isEnabled = true
            doneButton.backgroundColor = .trBlack
        } else {
            doneButton.isEnabled = false
            doneButton.backgroundColor = .trGray
        }
    }
    
    @objc private func didTapDoneButton() {
        
        guard let category = categoryTitleTextField.text,
              category.count > 0 else { return }
        
        do {
            try trackerCategoryStore.addNewCategory(category)
            
        } catch {
            print("Категория не сохранена")
        }

//        dismiss(animated: false) {
//            self.delegate?.updateCategory(category)
//        }
        
        
        
        NotificationCenter.default.post(name: .updateCategory, object: category)
        dismiss(animated: false) { [weak self] in
            self?.delegate?.updateTable()
        }
    }
}

extension NewCategoryViewController: UITextFieldDelegate {
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

extension NewCategoryViewController: SettingViewsProtocol {
    func setupView() {
        title = "Категория"
        categoryTitleTextField.delegate = self
        view.backgroundColor = .trWhite
        view.addSubviews(doneButton, categoryTitleTextField)
        doneButton.addTarget(self, action: #selector(didTapDoneButton), for: .touchUpInside)
        categoryTitleTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            categoryTitleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            categoryTitleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            categoryTitleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            categoryTitleTextField.heightAnchor.constraint(equalToConstant: 75),
            
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
}
