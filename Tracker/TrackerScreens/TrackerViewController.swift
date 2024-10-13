import UIKit

final class TrackerViewController: UIViewController {
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .trWhite
        return collectionView
    }()
    
    private let searchController: UISearchController = {
        let search = UISearchController()
        search.hidesNavigationBarDuringPresentation = false
        search.searchBar.setValue(Constants.cancel, forKey: "cancelButtonText")
        search.searchBar.placeholder = Constants.search
        return search
    }()
    
    private let emptyLogo = TrackerEmptyLogo(frame: .zero)
    private let emptyLabel = TrackerEmptyLabel(Constants.trackerEmptyLogo)
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.overrideUserInterfaceStyle = .light
        picker.backgroundColor = .trWhite
        picker.layer.cornerRadius = 8
        picker.layer.masksToBounds = true
        return picker
    }()
    
    private let filterButton: UIButton = {
        let button = UIButton()
        button.setTitle(Constants.filters, for: .normal)
        button.setTitleColor(.trWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        button.layer.cornerRadius = 16
        button.backgroundColor = .trBlue
        button.overrideUserInterfaceStyle = .light
        return button
    }()
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerRecordStore = TrackerRecordStore()
    private let trackerStore = TrackerStore()
    
    var trackers: [Tracker] = []
    
    var currentDate: Date = Date()
    var selectedDate: Date = Date()
    var categories: [TrackerCategory] = [] {
        didSet {
            filteredTrackers = categories
        }
    }
    
    private var selectedFilter: Filters? {
        didSet {
            filterStorage.filter = selectedFilter
        }
    }
    private let filterStorage = FilterStateStorage.shared
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
        getCategories()
        getTrackerRecords()
        showOnboarding()
        showTodayTrackers(date: currentDate)
        didSelectFilter(filter: filterStorage.filter)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AnalyticService().trackOpenScreen(screen: "Main")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        AnalyticService().trackCloseScreen(screen: "Main")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .addCategory, object: nil)
        AnalyticService().trackOpenScreen(screen: "Main")
    }
    
    private func showOnboarding() {
        if !OnboardingStateStorage.shared.isShowed {
            let vc = OnboardingPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    @objc private func getCategories(_ notification: Notification) {
        getCategories()
        showTodayTrackers(date: currentDate)
        didSelectFilter(filter: filterStorage.filter)
    }
    
    @objc private func didTapAddButton() {
        AnalyticService().trackClick(screen: "Main", item: "add_track")
        NotificationCenter.default.removeObserver(self, name: .addCategory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getCategories(_:)), name: .addCategory, object: nil)
        let vc = CreateTrackerViewController()
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
        
    }
    
    @objc private func didTapFilterButton() {
        AnalyticService().trackClick(screen: "Main", item: "filter")
        let vc = FilterViewController()
        vc.selectedFilter = selectedFilter
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        selectedDate = sender.date
        if let selectedFilter {
            didSelectFilter(filter: selectedFilter)
        } else {
            showTodayTrackers(date: sender.date)
        }
        updateEmptyState()
        collectionView.reloadData()
    }
    
    private func showTodayTrackers(date: Date) {
        let weekDay = Calendar.current.component(.weekday, from: date)
        
        filteredTrackers = categories.compactMap { category in
            var filteredTrackers = category.trackers.filter { tracker in
                tracker.schedule.contains(weekDay)
            }
            filteredTrackers.append(contentsOf: category.trackers.filter({ $0.schedule.isEmpty }))
            return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
        }
    }
    
    private func filterTrackers(for searchText: String) {
        if searchText.isEmpty {
            filteredTrackers = categories
        } else {
            filteredTrackers = categories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.title.localizedCaseInsensitiveContains(searchText)
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(title: category.title, trackers: filteredTrackers)
            }
        }
    }
    
    private func getCategories() {
        do {
            categories = try trackerCategoryStore.getCategoriesTracker()
        } catch {
            print("Can't get Categories in TrackerViewController")
        }
    }
    
    private func getTrackerRecords() {
        do {
            completedTrackers = try trackerRecordStore.getCompletedTrackers()
        } catch {
            print("Can't get TrackerRecords in TrackerViewController")
        }
    }
    
    private func dateFromDatePicker() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let stringDate = dateFormatter.string(from: datePicker.date)
        return dateFormatter.date(from: stringDate) ?? Date()
    }
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
        filterButton.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
        
        view.backgroundColor = .trWhite
        view.addSubviews(emptyLogo, emptyLabel, collectionView, filterButton)
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
            
            filterButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 130),
            filterButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -130),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        collectionView.register(CategoryHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderReusableView.reuseIdentifier)
    }
    
    private func setupNavBar() {
        title = Constants.trackers
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
        filterButton.isHidden = filteredTrackers.isEmpty
        if selectedFilter != nil && filteredTrackers.isEmpty {
            filterButton.isHidden = false
            emptyLogo.image = UIImage(named: "EmptyFilterResult")
            emptyLabel.text = Constants.emptyFilterResults
        }
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
        let weekDay = Calendar.current.component(.weekday, from: datePicker.date)
        let date = dateFromDatePicker()
        cell.updateID(id: tracker.id)
        cell.configureCell(tracker, weekDay: weekDay, date: date, completedTrackers: completedTrackers)
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
    func collectionView(_ collectionView: UICollectionView,
                        contextMenuConfigurationForItemAt indexPath: IndexPath,
                        point: CGPoint) -> UIContextMenuConfiguration? {
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.row]
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions in
            
            return UIMenu(children: [
                UIAction(title: tracker.isPinned ? Constants.pin : Constants.unpin) { [weak self] _ in
                    self?.pinTracker(at: indexPath, for: tracker)
                },
                UIAction(title: Constants.edit) { [weak self] _ in
                    AnalyticService().trackClick(screen: "Main", item: "edit")
                    self?.editTracker(at: indexPath, for: tracker)
                },
                UIAction(title: Constants.delete, attributes: .destructive) { [weak self] _ in
                    AnalyticService().trackClick(screen: "Main", item: "delete")
                    guard let self else { return }
                    TrackerAlert.showAlert(on: self, alertTitle: Constants.deleteTracker) { [weak self] in
                        self?.deleteTracker(at: indexPath, for: tracker)
                    }
                }
            ])
        }
    }
    
    private func deleteTracker(at indexPath: IndexPath, for tracker: Tracker) {
        trackerRecordStore.deleteTrackerRecord(tracker.id)
        trackerStore.deleteTracker(tracker.id)
        getCategories()
        getTrackerRecords()
    }
    
    private func editTracker(at indexPath: IndexPath, for tracker: Tracker) {
        let category = filteredTrackers[indexPath.section]
        let daysCount = completedTrackers.filter({ $0.id == tracker.id }).count
        let vc = NewOrEditTrackerViewController(trackerCategory: category,
                                                tracker: tracker,
                                                daysCount: daysCount,
                                                trackerType: !tracker.schedule.isEmpty ? .editRegular : .editUnregular )
        NotificationCenter.default.removeObserver(self, name: .editCategory, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getCategories(_:)), name: .editCategory, object: nil)
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func pinTracker(at indexPath: IndexPath, for tracker: Tracker) {
        
        
    
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

extension TrackerViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.isDragging {
            filterButton.alpha = 1
            let height = scrollView.frame.size.height
            let contentYOffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYOffset
            
            if distanceFromBottom < height {
                UIView.animate(withDuration: 2, delay: 0) { [weak self] in
                    self?.filterButton.alpha = 0
                }
            }
        }
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
        return datePicker.date <= Date()
    }
    
    func didTapCompletedButton(for cell: TrackerCollectionViewCell, isButtonTapped: Bool) {
        AnalyticService().trackClick(screen: "Main", item: "track")
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        let tracker = filteredTrackers[indexPath.section].trackers[indexPath.row]
        let date = dateFromDatePicker()
        if isButtonTapped {
            completedTrackers.append(TrackerRecord(id: tracker.id, date: date))
            trackerRecordStore.addNewTrackerRecord(id: tracker.id, date: date)
        } else {
            completedTrackers.removeAll(where: { $0.id == tracker.id && Calendar.current.isDate($0.date, equalTo: date, toGranularity: .day) })
            trackerRecordStore.deleteTrackerRecord(id: tracker.id, date: date)
        }
    }
}

extension TrackerViewController: FilterViewControllerDelegate {
    func didSelectFilter(filter: Filters?) {
        selectedFilter = filter
        filterButton.setTitleColor(selectedFilter != nil ? .trRed : .trWhite, for: .normal)
        showTodayTrackers(date: currentDate)
        guard let filter else { return }
        
        switch filter {
        case .allTrackers:
            filterAllTrackers()
        case .todayTrackers:
            filterTodayTrackers()
        case .doneTrackers:
            filterCompletedTrackers()
        case .activeTrackers:
            filterActiveTrackers()
        }
    }
    
    private func filterAllTrackers() {
        filteredTrackers = categories
    }
    
    private func filterTodayTrackers() {
        datePicker.date = currentDate
        showTodayTrackers(date: currentDate)
    }
    
    private func filterCompletedTrackers() {
        filteredTrackers = categories.compactMap { category in
            let completed = category.trackers.filter { tracker in
                completedTrackers.contains { $0.id == tracker.id }
            }
            return completed.isEmpty ? nil : TrackerCategory(title: category.title, trackers: completed)
        }
    }
    
    private func filterActiveTrackers() {
        filteredTrackers = categories.compactMap { category in
            let active = category.trackers.filter { tracker in
                !completedTrackers.contains { $0.id == tracker.id }
            }
            return active.isEmpty ? nil : TrackerCategory(title: category.title, trackers: active)
        }
    }
}
