//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Юрий Гриневич on 08.09.2024.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    static let categoriesNotification = Notification.Name(rawValue: "categoriesNotification")
    
    private let tableView = TrackerTableView()
    private let addButton = TrackerButton("Добавить категорию", .trBlack, .trWhite)
    private let emptyLogo = TrackerEmptyLogo(frame: .zero)
    private let emptyLabel = TrackerEmptyLabel("Привычки и события можно \n объединить по смыслу")
    
    private var selectedIndexPath: IndexPath?
    var categories: [TrackerCategory] = [] {
        didSet {
            updateEmptyState()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
        //Mock данные -------------------------------
        let tracker1 = Tracker(id: UUID(), title: "Создать", color: "tr1", emoji: "✊", schedule: [2, 3])
        let tracker2 = Tracker(id: UUID(), title: "Назначить", color: "tr2", emoji: "✍️", schedule: [2, 4])
        let tracker3 = Tracker(id: UUID(), title: "Решить", color: "tr3", emoji: "🤔", schedule: [5, 6])
        let tracker4 = Tracker(id: UUID(), title: "Заняться", color: "tr4", emoji: "🫣", schedule: [6, 7])
        let tracker5 = Tracker(id: UUID(), title: "Отдохнуть", color: "tr5", emoji: "🫠", schedule: [2, 6])
        
        let category1 = TrackerCategory(title: "Важное", trackers: [tracker1, tracker2])
        let category2 = TrackerCategory(title: "Не важное", trackers: [tracker3, tracker4, tracker5])
        
        categories = [category1, category2]
    }
    
    private func updateEmptyState() {
        if categories.isEmpty {
            emptyLogo.isHidden = false
            emptyLabel.isHidden = false
            tableView.isHidden = true
        } else {
            emptyLogo.isHidden = true
            emptyLabel.isHidden = true
            tableView.isHidden = false
        }
    }
    
    private func setupView() {
        title = "Категория"
        view.backgroundColor = .trWhite
        
        tableView.dataSource = self
        tableView.delegate = self
        addButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        
        view.addSubviews(tableView, emptyLogo, emptyLabel, addButton)
        
        NSLayoutConstraint.activate([
            
            emptyLogo.widthAnchor.constraint(equalToConstant: 80),
            emptyLogo.heightAnchor.constraint(equalToConstant: 80),
            emptyLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyLogo.bottomAnchor, constant: 8),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyLabel.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addButton.topAnchor, constant: -20),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    @objc private func addCategory() {
        print("Add Category button tapped")
        
        NotificationCenter.default.post(name: CategoryViewController.categoriesNotification,
                                        object: categories)
        dismiss(animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        cell.textLabel?.text = categories[indexPath.row].title
        cell.backgroundColor = .trBackground
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Сначала убираем галочку с ранее выбранной ячейки, если она существует
        if let previousIndexPath = selectedIndexPath {
            if previousIndexPath != indexPath {
                let previousCell = tableView.cellForRow(at: previousIndexPath)
                previousCell?.accessoryType = .none
            }
        }
        
        // Устанавливаем галочку на текущей выбранной ячейке
        let currentCell = tableView.cellForRow(at: indexPath)
        currentCell?.accessoryType = .checkmark
        
        // Обновляем выбранную ячейку
        selectedIndexPath = indexPath
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
