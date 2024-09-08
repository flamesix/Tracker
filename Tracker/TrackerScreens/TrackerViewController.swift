//
//  TrackerViewController.swift
//  Tracker
//
//  Created by Юрий Гриневич on 25.08.2024.
//

import UIKit

final class TrackerViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private let searchController: UISearchController = {
        let search = UISearchController()
        search.hidesNavigationBarDuringPresentation = false
        search.searchBar.setValue("Отменить", forKey: "cancelButtonText")
        search.searchBar.placeholder = "Поиск"
        return search
    }()
    
    private let emptyLogo = TrackerEmptyLogo(frame: .zero)
    private let emptyLabel = TrackerEmptyLabel("Что будем отслеживать?")
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.addTarget(TrackerViewController.self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    var trackers: [Tracker] = [
        Tracker(id: UUID(), title: "Создать", color: "tr1", emoji: "😜", schedule: "5 дней"),
        Tracker(id: UUID(), title: "Назначить", color: "tr2", emoji: "😀", schedule: "3 дня"),
        Tracker(id: UUID(), title: "Запомнить позвонить, чтобы назначить и создать", color: "tr3", emoji: "😎", schedule: "0 дней"),
    ]
    
    var currentDate: Date = Date()
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    private var filteredTrackers: [TrackerCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func didTapAddButton() {
        let vc = CreateTrackerViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
        
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    private func updateEmptyState() {
        if filteredTrackers.flatMap({ $0.title }).isEmpty {
            emptyLogo.isHidden = false
            emptyLabel.isHidden = false
            collectionView.isHidden = true
        } else {
            emptyLogo.isHidden = true
            emptyLabel.isHidden = true
            collectionView.isHidden = false
        }
    }
    
    private func filterTrackers(for searchText: String) {
        let filteredCategories = categories.map { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.title.lowercased().contains(searchText.lowercased())
            }
            return TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
        
        if searchText.isEmpty {
            filteredTrackers = categories
        } else {
            filteredTrackers = filteredCategories.filter { !$0.trackers.isEmpty }
        }
        updateEmptyState()
    }
    
    private func setupView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchController.searchBar.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        
        setupNavBar()
        
        view.backgroundColor = .trWhite
        if trackers.isEmpty {
            view.addSubviews(emptyLogo, emptyLabel)
            
            NSLayoutConstraint.activate([
                
                emptyLogo.widthAnchor.constraint(equalToConstant: 80),
                emptyLogo.heightAnchor.constraint(equalToConstant: 80),
                emptyLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                emptyLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                
                emptyLabel.topAnchor.constraint(equalTo: emptyLogo.bottomAnchor, constant: 8),
                emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                emptyLabel.heightAnchor.constraint(equalToConstant: 18),
                
            ])
        } else {
            view.addSubview(collectionView)
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        }
    }
    
    private func setupNavBar() {
        title = "Трекеры"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(named: "addButton"), style: .done, target: self, action: #selector(didTapAddButton)), animated: true)
        navigationItem.leftBarButtonItem?.tintColor = .trBlack
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        let tracker = trackers[indexPath.row]
        cell.configureCell(tracker)
        return cell
    }
}

extension TrackerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard indexPaths.count > 0 else {
            return nil
        }
        
        let indexPath = indexPaths[0]
        
        return UIContextMenuConfiguration(actionProvider: { actions in
            return UIMenu(children: [
                UIAction(title: "Закрепить") { _ in
                    print("Закрепить")
                },
                UIAction(title: "Редактировать") { _ in
                    print("Редактировать")
                },
                UIAction(title: "Удалить", attributes: .destructive) { _ in
                    print("Удалить")
                    
                }
            ])
        })
    }
}

extension TrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 9
        let width = (collectionView.bounds.width - spacing) / 2
        return CGSize(width: width, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
}

extension TrackerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTrackers(for: searchText)
        updateEmptyState()
        collectionView.reloadData()
    }
}
