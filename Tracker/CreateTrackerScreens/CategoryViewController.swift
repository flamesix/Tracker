//
//  CategoryViewController.swift
//  Tracker
//
//  Created by Юрий Гриневич on 08.09.2024.
//

import UIKit

final class CategoryViewController: UIViewController {
    
    private let tableView = TrackerTableView()
    private let addButton = TrackerButton("Добавить категорию", .trBlack, .trWhite)
    private let emptyLogo = TrackerEmptyLogo(frame: .zero)
    private let emptyLabel = TrackerEmptyLabel("Привычки и события можно \n объединить по смыслу")
    
    private var selectedIndexPath: IndexPath?
    var categories: [TrackerCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        title = "Категория"
        view.backgroundColor = .trWhite
        
        tableView.dataSource = self
        tableView.delegate = self
        addButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        
        view.addSubviews(tableView, addButton)
        
        if categories.isEmpty {
            view.addSubviews(emptyLogo, emptyLabel)
            
            NSLayoutConstraint.activate([
                
                emptyLogo.widthAnchor.constraint(equalToConstant: 80),
                emptyLogo.heightAnchor.constraint(equalToConstant: 80),
                emptyLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                emptyLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                
                emptyLabel.topAnchor.constraint(equalTo: emptyLogo.bottomAnchor, constant: 8),
                emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                emptyLabel.heightAnchor.constraint(equalToConstant: 36),
                
                addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
                addButton.heightAnchor.constraint(equalToConstant: 60)
                
            ])
        } else {
            NSLayoutConstraint.activate([
                
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
    }
    
    @objc private func addCategory() {
        print("Add Category button tapped")
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
