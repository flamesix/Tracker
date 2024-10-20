import UIKit

enum TrackerType {
    case regular
    case unregular
    case editRegular
    case editUnregular
    
    var numberOfRowsInSection: Int {
        switch self {
        case .regular, .editRegular:
            2
        case .unregular, .editUnregular:
            1
        }
    }
    
    var title: String {
        switch self {
        case .regular:
            Constants.newHabit
        case .unregular:
            Constants.newUnregularEvent
        case .editRegular:
            Constants.editRegular
        case .editUnregular:
            Constants.editUnregular
        }
    }
    
    var isRegular: Bool {
        switch self {
        case .regular, .editRegular:
            true
        case .unregular, .editUnregular:
            false
        }
    }
    
    var isEdit: Bool {
        switch self {
        case .regular, .unregular:
            false
        case .editRegular, .editUnregular:
            true
        }
    }
    
    var constraint: CGFloat {
        switch self {
        case .regular, .unregular:
            24
        case .editRegular, .editUnregular:
            102
        }
    }
}

final class NewOrEditTrackerViewController: UIViewController {
    
    private let trackerCategoryStore = TrackerCategoryStore()
    private let trackerStore = TrackerStore()
    
    public var categories: [TrackerCategory] = []
    private var emojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                                    "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                                    "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private var colors: [String] = Array(1...18).map { String("tr\($0)")}
    enum EmojiColorSection: String, CaseIterable {
        case emoji
        case color
        
        var title: String {
            switch self {
            case .emoji:
                return "Emoji"
            case .color:
                return Constants.color
            }
        }
    }
    
    private var selectedColor: String = "" {
        didSet {
            checkCreateButtonActive()
        }
    }
    
    private var selectedEmoji: String = "" {
        didSet {
            checkCreateButtonActive()
        }
    }
    
    private var category: String = "" {
        didSet {
            checkCreateButtonActive()
        }
    }
    
    private var scheduleDescription: String = "" {
        didSet {
            checkCreateButtonActive()
        }
    }
    
    private var trackerTitle: String = "" {
        didSet {
            checkCreateButtonActive()
        }
    }
    
    private var selectedItems: [Int: IndexPath] = [:]
    private var schedule: [Int] = []
    private var selectedDays: [WeekDay: Bool] = [:]
    
    private var daysCount: Int?
    private var trackerType: TrackerType = .regular
    private var trackerCategory: TrackerCategory?
    private var tracker: Tracker?
    
    // MARK: - UIComponents
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()
    
    private let addTrackerNameTextField = TrackerTextField(placeholder: Constants.enterTrackerName)
    private let tableView = TrackerTableView()
    private let createButton = TrackerButton(Constants.create, .trGray, .trWhite)
    private let cancelButton = TrackerButton(Constants.cancel, .clear, .trRed, 1, .trRed)
    private let buttonStackView = TrackerButtonStackView()
    private let warningLabel = TrackerWarningLabel()
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .trBlack
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 32, weight: .bold)
        guard let daysCount else { return label }
        let dayString = String.localizedStringWithFormat(
            NSLocalizedString("numberOfDays", comment: "Number of days completed"),
            daysCount
        )
        label.text = dayString
        return label
    }()
    
    // MARK: - Init
    init(trackerType: TrackerType) {
        super.init(nibName: nil, bundle: nil)
        self.trackerType = trackerType
    }
    
    init(trackerCategory: TrackerCategory, tracker: Tracker, daysCount: Int, trackerType: TrackerType) {
        super.init(nibName: nil, bundle: nil)
        self.trackerCategory = trackerCategory
        self.tracker = tracker
        self.daysCount = daysCount
        self.trackerType = trackerType
        
        if trackerType.isEdit {
            updateUIforEditTracker(trackerCategory, tracker: tracker)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        updateCategories()
        setupHideKeyboardOnTap()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateCategory(_:)), name: .updateCategory, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .updateCategory, object: nil)
    }
    
    private func updateUIforEditTracker(_ trackerCategory: TrackerCategory, tracker: Tracker) {
        trackerTitle = tracker.title
        selectedEmoji = tracker.emoji
        selectedColor = tracker.color
        schedule = tracker.schedule
        category = trackerCategory.title
        scheduleDescription = makeScheduleDescription(schedule)
        addTrackerNameTextField.text = trackerTitle
        updateSelectedDaysToEdit(schedule)
        updateSelectedItems(tracker)
        createButton.setTitle(Constants.save, for: .normal)
        tableView.reloadData()
        collectionView.reloadData()
    }
    
    private func makeScheduleDescription(_ schedule: [Int]) -> String {
        var description: [String] = []
        var sortedSchedule: [Int] = schedule.sorted(by: <)
        if !schedule.isEmpty && sortedSchedule[0] == 1 {
            sortedSchedule.remove(at: 0)
            sortedSchedule.append(1)
        }
        for day in sortedSchedule {
            if day == 1 {
                description.append(WeekDay.allCases[6].short)
            } else {
                description.append(WeekDay.allCases[day - 2].short)
            }
        }
        return description.joined(separator: ", ")
    }
    
    private func updateSelectedDaysToEdit(_ schedule: [Int]) {
        for day in schedule {
            switch day {
            case 1: selectedDays[.sunday] = true
            case 2: selectedDays[.monday] = true
            case 3: selectedDays[.tuesday] = true
            case 4: selectedDays[.wednesday] = true
            case 5: selectedDays[.thursday] = true
            case 6: selectedDays[.friday] = true
            case 7: selectedDays[.saturday] = true
            default:
                break
            }
        }
    }
    
    private func updateSelectedItems(_ tracker: Tracker) {
        let emojiIndexPath = IndexPath(row: emojis.firstIndex(of: tracker.emoji ) ?? 0, section: 0)
        let colorIndexPath = IndexPath(row: colors.firstIndex(of: tracker.color) ?? 0, section: 1)
        selectedItems[0] = emojiIndexPath
        selectedItems[1] = colorIndexPath
    }
    
    private func updateCategories() {
        do {
            categories = try trackerCategoryStore.getCategory()
        } catch {
            print("Can't update categories in NewTrackerViewController")
        }
    }
    
    private func createTracker(color: String, emoji: String) {
        switch trackerType.isEdit {
        case true:
            guard let tracker else { return }
            let editedTracker = Tracker(id: tracker.id,
                                        title: trackerTitle,
                                        color: color,
                                        emoji: emoji,
                                        isPinned: false,
                                        schedule: schedule)
            trackerStore.updateTracker(editedTracker, category)
            NotificationCenter.default.post(name: .editCategory, object: nil)
        case false:
            let tracker = Tracker(id: UUID(),
                                  title: trackerTitle,
                                  color: color,
                                  emoji: emoji,
                                  isPinned: false,
                                  schedule: schedule)
            trackerStore.addNewTracker(tracker, category)
            NotificationCenter.default.post(name: .addCategory, object: TrackerCategory(title: category, trackers: [tracker]))
        }
    }
    
    @objc private func didTapCancelButton() {
        if let window = UIApplication.shared.windows.first {
            window.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func didTapCreateButton() {
        createTracker(color: selectedColor, emoji: selectedEmoji)
        
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
        let viewModel = CategoryViewModel()
        vc.initViewModel(viewModel: viewModel)
        viewModel.selectedCategory = category
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
    
    private func showWaringLabel(isWarned: Bool) {
        isWarned ? view.addSubviews(warningLabel) : warningLabel.removeFromSuperview()
        warningLabel.isHidden = !isWarned
        addConstraints()
    }
    
    private func makeCreateButtonActive() {
        createButton.isEnabled = true
        createButton.backgroundColor = .trBlack
    }
    
    private func makeCreateButtonInactive() {
        createButton.isEnabled = false
        createButton.backgroundColor = .trGray
    }
    
    private func checkCreateButtonActive() {
        switch trackerType {
        case .regular, .editRegular:
            if !trackerTitle.isEmpty && !scheduleDescription.isEmpty && !category.isEmpty && !selectedColor.isEmpty && !selectedEmoji.isEmpty {
                makeCreateButtonActive()
            } else {
                makeCreateButtonInactive()
            }
        case .unregular, .editUnregular:
            if !trackerTitle.isEmpty && !category.isEmpty && !selectedColor.isEmpty && !selectedEmoji.isEmpty {
                makeCreateButtonActive()
            } else {
                makeCreateButtonInactive()
            }
        }
    }
    
    @objc private func didChangeTrackerName(_ sender: UITextField) {
        guard let trackerTitle = sender.text else { return }
        self.trackerTitle = trackerTitle
    }
}

// MARK: - UITableViewDataSource & Delegate
extension NewOrEditTrackerViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        trackerType.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryScheduleTableViewCell.reuseIdentifier, for: indexPath) as? CategoryScheduleTableViewCell else { return UITableViewCell() }
        cell.accessoryType = .disclosureIndicator
        cell.configure(isRegularEvent: trackerType.isRegular, indexPath: indexPath, schedule: scheduleDescription, category: category)
        return cell
    }
}

extension NewOrEditTrackerViewController: UITableViewDelegate {
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
extension NewOrEditTrackerViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let currentText = textField.text,
              let stringRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: stringRange, with: string)
        
        switch updatedText.count {
        case 0...38:
            showWaringLabel(isWarned: false)
        case 39:
            showWaringLabel(isWarned: true)
        default:
            break
        }
        return updatedText.count <= 39
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - Delegates
extension NewOrEditTrackerViewController: ScheduleViewControllerDelegate {
    func updateScheduleSelection(with selectedDays: [WeekDay : Bool], schedule: [Int]) {
        let sortedDays = selectedDays.filter({ $0.value == true }).keys.sorted(by: { $0.sort < $1.sort })
        scheduleDescription = sortedDays.map { $0.short }.joined(separator: ", ")
        self.selectedDays = selectedDays
        self.schedule = schedule
        tableView.reloadData()
    }
}

extension NewOrEditTrackerViewController: CategoryViewControllerDelegate {
    func updateCategorySelection(with category: String) {
        self.category = category
        tableView.reloadData()
    }
}

// MARK: - SettingView
extension NewOrEditTrackerViewController: SettingViewsProtocol {
    func setupView() {
        setupTableView()
        setupCollectionView()
        
        addTrackerNameTextField.delegate = self
        addTrackerNameTextField.addTarget(self, action: #selector(didChangeTrackerName), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(didTapCancelButton), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreateButton), for: .touchUpInside)
        createButton.isEnabled = false
        
        title = trackerType.title
        view.backgroundColor = .trWhite
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(createButton)
        view.addSubviews(scrollView)
        scrollView.addSubviews(contentView)
        switch trackerType {
        case .regular, .unregular:
            contentView.addSubviews(addTrackerNameTextField, tableView, collectionView, buttonStackView)
        case .editRegular, .editUnregular:
            contentView.addSubviews(addTrackerNameTextField, tableView, collectionView, buttonStackView, daysCountLabel)
        }
        
        addConstraints()
        
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
            
            addTrackerNameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: trackerType.constraint),
            addTrackerNameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            addTrackerNameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            addTrackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: addTrackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: trackerType.isRegular ? 150 : 75),
            
            collectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            collectionView.heightAnchor.constraint(greaterThanOrEqualToConstant: 492),

            buttonStackView.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 16),
            buttonStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            
        ])
        if !warningLabel.isHidden {
            NSLayoutConstraint.activate([
                warningLabel.topAnchor.constraint(equalTo: addTrackerNameTextField.bottomAnchor, constant: 8),
                warningLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 45),
                warningLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -45),
                warningLabel.heightAnchor.constraint(equalToConstant: 22),
                
            ])
        }
        
        if trackerType.isEdit {
            NSLayoutConstraint.activate([
                daysCountLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
                daysCountLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
                daysCountLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
                daysCountLabel.heightAnchor.constraint(equalToConstant: 38),
            ])
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = trackerType.isRegular ? .singleLine : .none
    }
    
    private func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(EmojiCollectionViewCell.self, forCellWithReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier)
        collectionView.register(ColorCollectionViewCell.self, forCellWithReuseIdentifier: ColorCollectionViewCell.reuseIdentifier)
        collectionView.register(CategoryHeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderReusableView.reuseIdentifier)
    }
}

// MARK: - UICollectionViewDataSource
extension NewOrEditTrackerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        EmojiColorSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch EmojiColorSection.allCases[section] {
        case .emoji:
            emojis.count
        case .color:
            colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CategoryHeaderReusableView.reuseIdentifier, for: indexPath) as? CategoryHeaderReusableView else { return UICollectionReusableView() }
        let sectionTitle = EmojiColorSection.allCases[indexPath.section].title
        header.configure(with: sectionTitle)
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch EmojiColorSection.allCases[indexPath.section] {
        case .emoji:
            guard let emojiCell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCollectionViewCell.reuseIdentifier, for: indexPath) as? EmojiCollectionViewCell else { return UICollectionViewCell() }
            
            let emoji = emojis[indexPath.row]
            emojiCell.configure(with: emoji)
            emojiCell.configureSelection(isSelected: selectedItems[indexPath.section] == indexPath)
            
            return emojiCell
        case .color:
            guard let colorCell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCollectionViewCell.reuseIdentifier, for: indexPath) as? ColorCollectionViewCell else { return UICollectionViewCell() }
            
            let color = colors[indexPath.row]
            colorCell.configure(with: color)
            colorCell.configureSelection(isSelected: selectedItems[indexPath.section] == indexPath)
            
            return colorCell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension NewOrEditTrackerViewController: UICollectionViewDelegate {
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
            let color = colors[indexPath.row]
            selectedColor = color
            guard let colorCell = collectionView.cellForItem(at: indexPath) as? ColorCollectionViewCell else { return }
            colorCell.configureSelection(isSelected: true)
        default:
            break
        }
        
        selectedItems[indexPath.section] = indexPath
    }
    
}

// MARK: - UICollectionViewFlowLayout
extension NewOrEditTrackerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing: CGFloat = 5
        let width = (collectionView.frame.width - spacing * 5) / 6
        return CGSize(width: width, height: width)
    }
    
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
