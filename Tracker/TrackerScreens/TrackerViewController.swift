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
        picker.locale = Locale(identifier: "ru_RU")
        return picker
    }()
    
    var trackers: [Tracker] = []
    
    var currentDate: Date = Date()
    var categories: [TrackerCategory] = []
    
    var completedTrackers: [TrackerRecord] = []
    private var filteredTrackers: [TrackerCategory] = [] {
        didSet {
            updateEmptyState()
            collectionView.reloadData()
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
        //Mock данные ---------------------------------
        filteredTrackers = [category1, category2]
        filterTrackersForDate(date: Date())
        
        
    }
    
    @objc private func didTapAddButton() {
        let vc = CreateTrackerViewController()
        present(UINavigationController(rootViewController: vc), animated: true)
        
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        filterTrackersForDate(date: sender.date)
        updateEmptyState()
        collectionView.reloadData()
    }
    
    private func filterTrackersForDate(date: Date) {
        let weekDay = Calendar.current.component(.weekday, from: date)
        
        filteredTrackers = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(weekDay)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }
    
    private func updateEmptyState() {
        if filteredTrackers.isEmpty {
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
        let trackersToFilter = categories
        let searchResult = trackersToFilter.map { category in
            let filteredResult = category.trackers.filter({ $0.title.localizedCaseInsensitiveContains(searchText) })
            return TrackerCategory(title: category.title, trackers: filteredResult)
        }
        if let result = searchResult.first, result.trackers.isEmpty {
            filteredTrackers = []
        } else {
            filteredTrackers = searchResult
        }
        if searchText.isEmpty {
            filteredTrackers = categories
        }
    }
    
    private func setupView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        searchController.searchBar.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        collectionView.register(CategoryHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderReusableView.reuseIdentifier)
        
        setupNavBar()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        view.backgroundColor = .trWhite
        view.addSubviews(emptyLogo, emptyLabel, collectionView)
        updateEmptyState()
        
        
        NSLayoutConstraint.activate([
            
            emptyLogo.widthAnchor.constraint(equalToConstant: 80),
            emptyLogo.heightAnchor.constraint(equalToConstant: 80),
            emptyLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            emptyLabel.topAnchor.constraint(equalTo: emptyLogo.bottomAnchor, constant: 8),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            emptyLabel.heightAnchor.constraint(equalToConstant: 18),
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
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
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        filteredTrackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        filteredTrackers[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        cell.delegate = self
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.item]
        cell.configureCell(tracker, weekDay: Calendar.current.component(.weekday, from: datePicker.date), completedTrackers: completedTrackers)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderReusableView.reuseIdentifier, for: indexPath) as? CategoryHeaderReusableView else { return  UICollectionReusableView() }
        let category = filteredTrackers[indexPath.section]
        header.configure(with: category)
        return header
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
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
    }
}

extension TrackerViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterTrackers(for: searchText)
        updateEmptyState()
        collectionView.reloadData()
    }
}

extension TrackerViewController: TrackerCollectionViewCellDelegate {
    func didTapCompletedButton(for cell: TrackerCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.row]
        completedTrackers.append(TrackerRecord(id: tracker.id, date: Date()))
    }
}
