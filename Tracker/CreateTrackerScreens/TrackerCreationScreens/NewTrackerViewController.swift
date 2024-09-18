//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Юрий Гриневич on 09.09.2024.
//

import UIKit

final class NewTrackerViewController: UIViewController {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    
    public var categories: [TrackerCategory] = []
    private var emojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                                    "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                                    "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private var mockColors: [String] = Array(1...18).map { String("tr\($0)")}
    enum EmojiColorSection: String, CaseIterable {
        case emoji = "Emoji"
        case color = "Цвет"
    }
    private var selectedColor: String = ""
    private var selectedEmoji: String = ""
    private var selectedItems: [Int: IndexPath] = [:]
    
    private var isRegularEvent: Bool = true
    private var category: String = ""
    private var scheduleDescription: String = ""
    
    private var createdCategory: TrackerCategory?
    private var trackerTitle: String = ""
    private var schedule: [Int] = []
    private var selectedDays: [WeekDay: Bool] = [:]
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
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
        updateCategories()
        //        setupHideKeyboardOnTap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCategory(_:)), name: .updateCategory, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .updateCategory, object: nil)
    }
    
    private func updateCategories() {
        do {
            categories = try trackerCategoryStore.getCategory()
            print(categories)
        } catch {
            print("Can't update categories in NewTrackerViewController")
        }
    }
    
    private func createTracker(color: String, emoji: String) -> Tracker {
        let tracker = Tracker(id: UUID(),
                              title: trackerTitle,
                              color: color,
                              emoji: emoji,
                              schedule: schedule)
        return tracker
    }
    
    @objc private func didTapCancelButton() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func didTapCreateButton() {
        createdCategory = TrackerCategory(title: category, trackers: [createTracker(color: selectedColor, emoji: selectedEmoji)])
        
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

// MARK: - UITableViewDataSource & Delegate
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

// MARK: - UITextFieldDelegate
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

// MARK: - Delegates
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

// MARK: - SettingView
extension NewTrackerViewController: SettingViewsProtocol {
    func setupView() {
        setupTableView()
        setupCollectionView()
        
        addTrackerNameTextField.delegate = self
        
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        createButton.isEnabled = false
        
        title = isRegularEvent ? "Новая привычка" : "Новое нерегулярное событие"
        view.backgroundColor = .trWhite
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        view.addSubviews(addTrackerNameTextField, tableView, collectionView, buttonStackView)
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
                
                collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
                collectionView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -18),
                
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
                
                collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
                collectionView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor, constant: -18),
                
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
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        collectionView.register(CategoryHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderReusableView.reuseIdentifier)
    }
}

// MARK: - UICollectionView
extension NewTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        EmojiColorSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch EmojiColorSection.allCases[section] {
        case .emoji:
            emojis.count
        case .color:
            mockColors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderReusableView.reuseIdentifier, for: indexPath) as? CategoryHeaderReusableView else { return UICollectionReusableView() }
        let sectionTitle = EmojiColorSection.allCases[indexPath.section].rawValue
        header.configure(with: sectionTitle)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch EmojiColorSection.allCases[indexPath.section] {
        case .emoji:
            guard let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }
            
            let emoji = emojis[indexPath.row]
            emojiCell.configure(with: emoji)
            
            return emojiCell
        case .color:
            guard let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            
            let color = mockColors[indexPath.row]
            colorCell.configure(with: color)
            
            return colorCell
        }
    }
}

extension NewTrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let previouslySelectedIndexPath = selectedItems[indexPath.section] {
            
            switch indexPath.section {
            case 0:
                
                guard let previouslySelectedCell = collectionView.cellForItem(
                    at: previouslySelectedIndexPath
                ) as? EmojiCollectionViewCell else { return }
                previouslySelectedCell.configureSelection(isSelected: false)
                collectionView.deselectItem(at: previouslySelectedIndexPath, animated: true)
            case 1:
                
                guard let previouslySelectedCell = collectionView.cellForItem(
                    at: previouslySelectedIndexPath
                ) as? ColorCollectionViewCell else { return }
                previouslySelectedCell.configureSelection(isSelected: false)
                collectionView.deselectItem(at: previouslySelectedIndexPath, animated: true)
            default:
                break
            }
        }
        
        switch indexPath.section {
        case 0:
            let emoji = emojis[indexPath.row]
            selectedEmoji = emoji
            guard let emojiCell = collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell else { return }
            emojiCell.configureSelection(isSelected: true)
        case 1:
            let color = mockColors[indexPath.row]
            selectedColor = color
            guard let colorCell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else { return }
            colorCell.configureSelection(isSelected: true)
        default:
            break
        }
        
        selectedItems[indexPath.section] = indexPath
    }
    
}

extension NewTrackerViewController: UICollectionViewDelegateFlowLayout {
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    ////        let spacing: CGFloat = 5
    //        let width = (collectionView.bounds.width) / 6
    //        return CGSize(width: width, height: width)
    //    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    }
}
