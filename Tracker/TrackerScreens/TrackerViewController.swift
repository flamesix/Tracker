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
    
    private let store = Store.shared
    private let trackerStore = TrackerStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var trackers: [Tracker] = []
    
    var currentDate: Date = Date()
    var selectedDate: Date = Date()
    var categories: [TrackerCategory] = [] {
        didSet {
            filteredTrackers = categories
        }
    }
    
    private var completedTrackersIDs: Set<UUID> = []
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
        showTodayTrackers(date: currentDate)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .addCategory, object: nil)
    }
    
    @objc private func getCategories(_ notification: Notification) {
        guard let category = notification.object as? TrackerCategory else { return }
        categories.append(category)
        showTodayTrackers(date: currentDate)
    }
    
    @objc private func didTapAddButton() {
        NotificationCenter.default.removeObserver(self, name: .addCategory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getCategories(_:)), name: .addCategory, object: nil)
        let vc = CreateTrackerViewController()
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
        
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        showTodayTrackers(date: sender.date)
        updateEmptyState()
        collectionView.reloadData()
    }
    
    private func showTodayTrackers(date: Date) {
        let weekDay = Calendar.current.component(.weekday, from: date)
        
        filteredTrackers = categories.compactMap { category in
            let filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(weekDay)
            }
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
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
    
//    private func udateDate() {
//        do {
//            completedTrackers = try trackerRecordStore.getCompletedTrackers()
//            updateExecutedTrackerIds()
//            let category = try store.getCategoriesTracker()
//            updateTargetDayTrackers(category)
//        } catch {
//            print("Данные не доступны")
//        }
//    }
}

extension TrackerViewController: CreateTrackerViewControllerDelegate {
    func pushCategories() -> [TrackerCategory] {
        categories
    }
}

extension TrackerViewController: SettingViewsProtocol {
    func setupView() {
        setupCollectionView()
        
        searchController.searchBar.delegate = self
        
        setupNavBar()
        datePicker.addTarget(self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        
        view.backgroundColor = .trWhite
        view.addSubviews(emptyLogo, emptyLabel, collectionView)
        addConstraints()
        updateEmptyState()
    }
    
    func addConstraints() {
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
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        collectionView.register(CategoryHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderReusableView.reuseIdentifier)
    }
    
    private func setupNavBar() {
        title = "Трекеры"
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationItem.searchController = searchController
        
        navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(named: "addButton"), style: .done, target: self, action: #selector(didTapAddButton)), animated: true)
        navigationItem.leftBarButtonItem?.tintColor = .trBlack
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
    
    private func updateEmptyState() {
        emptyLogo.isHidden = !filteredTrackers.isEmpty
        emptyLabel.isHidden = !filteredTrackers.isEmpty
        collectionView.isHidden = filteredTrackers.isEmpty
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
        cell.id = tracker.id
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
    func isNotFutureDate() -> Bool {
       return datePicker.date <= currentDate
    }
    
    func didTapCompletedButton(for cell: TrackerCollectionViewCell) {
//        guard let indexPath = collectionView.indexPath(for: cell) else { return }
//        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.row]
//        let date = datePicker.date
////        completedTrackers.append(TrackerRecord(id: tracker.id, date: date))
        print("didTapCompletedButton(for cell: TrackerCollectionViewCell)")
    }
    
    func didTapCompletedButton(_ id: UUID, _ status: Bool) {
        print("didTapCompletedButton(_ id: UUID, _ status: Bool)")
        if completedTrackersIDs.contains(id) {
            guard let index = completedTrackers.firstIndex(where: { $0.id == id }) else {
                print("Не нашел трекер во время изменения статуса")
                return
            }
            if !status {
//                let selectedDate = Calendar.current.dateComponents([.day, .month, .year], from: selectedDate)
                for dateCompletedDate in completedTrackers[index].date {
//                    let dateCompleted = Calendar.current.dateComponents([.day, .month, .year], from: dateCompletedDate)
                    if selectedDate == dateCompletedDate {
                        trackerRecordStore.deleteTrackerRecord(id: id, date: dateCompletedDate)
                        return
                    }
                }
            }
        }
        trackerRecordStore.addNewTrackerRecord(id: id, date: selectedDate)
    }
}
