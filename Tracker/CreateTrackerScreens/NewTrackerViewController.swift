//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Юрий Гриневич on 09.09.2024.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    
    public var categories: [TrackerCategory] = []
    private var mockColors: [String] = Array(1...18).map { String("tr\($0)")}
    
    private var isRegularEvent: Bool = true
    private var category: String = ""
    private var scheduleDescription: String = ""
    
    private var createdCategory: TrackerCategory?
    private var trackerTitle: String = ""
    private var schedule: [Int] = []
    private var selectedDays: [WeekDay: Bool] = [:]
    
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
//        setupHideKeyboardOnTap() ///Убрал, так как новый трекер можно добить (кнопка становится активной), только нажав Enter на экранной клавиатуре. Пока не придумал как оптимизировать...
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCategory(_:)), name: .updateCategory, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .updateCategory, object: nil)
    }
    
    private func createTracker() -> Tracker {
            let tracker = Tracker(id: UUID(),
                                  title: trackerTitle,
                                  color: mockColors.randomElement() ?? "tr1",
                                  emoji: "🫡", schedule: schedule)
            return tracker
    }
    
    @objc private func didTapCancelButton() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func didTapCreateButton() {
        createdCategory = TrackerCategory(title: category, trackers: [createTracker()])
        
        NotificationCenter.default.post(name: .addCategory, object: createdCategory)
        
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func updateCategory(_ notification: Notification) {
        guard let category = notification.object as? String else { return }
        self.category = category
        categories.append(TrackerCategory(title: category, trackers: []))
        tableView.reloadData()
    }
    
    private func showScheduleViewController() {
        let vc = ScheduleViewController()
        vc.schedule = schedule
        vc.selectedDays = selectedDays
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func showCategoryViewController() {
        let vc = CategoryViewController()
        vc.categories = categories
        vc.selectedCategory = category
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension NewTrackerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isRegularEvent ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryScheduleTableViewCell.reuseIdentifier, for: indexPath) as? CategoryScheduleTableViewCell else { return UITableViewCell() }
        cell.accessoryType = .disclosureIndicator
        cell.configure(isRegularEvent: isRegularEvent, indexPath: indexPath, schedule: scheduleDescription, category: category)
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
        
    }
    
    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {
        switch reason {
        case .committed:
            guard let trackerTitle = textField.text else { return }
            if !scheduleDescription.isEmpty && !category.isEmpty {
                self.trackerTitle = trackerTitle
                createButton.isEnabled = true
                createButton.backgroundColor = .trBlack
            }
        case .cancelled:
            createButton.isEnabled = false
            createButton.backgroundColor = .trGray
        @unknown default:
            print("Cannot Handle Unknown Reason")
        }
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

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func updateScheduleSelection(with selectedDays: [WeekDay : Bool], schedule: [Int]) {
        scheduleDescription = selectedDays.keys.map { $0.short }.joined(separator: ", ")
        self.selectedDays = selectedDays
        self.schedule = schedule
        tableView.reloadData()
    }
}

extension NewTrackerViewController: CategoryViewControllerDelegate {
    func updateCategorySelection(with category: String) {
        self.category = category
        tableView.reloadData()
    }
}


extension NewTrackerViewController: SettingViewsProtocol {
    func setupView() {
        setupTableView()
        
        addTrackerNameTextField.delegate = self
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        createButton.isEnabled = false
        
        title = isRegularEvent ? "Новая привычка" : "Новое нерегулярное событие"
        view.backgroundColor = .trWhite
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        view.addSubviews(addTrackerNameTextField, tableView, buttonStackView)
        addConstraints()
        
    }
    
    func addConstraints() {
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
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = isRegularEvent ? .singleLine : .none
    }
}
