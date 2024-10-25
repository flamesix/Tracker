import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func updateScheduleSelection(with selectedDays: [WeekDay: Bool], schedule: [Int])
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let contentView = UIView()
        return contentView
    }()
    
    private lazy var doneButton = TrackerButton(Constants.done, .trGray, .trWhite)
    private lazy var tableView = TrackerTableView()
    
    var selectedDays: [WeekDay: Bool] = [:]
    var schedule: [Int] = [] {
        didSet {
            updateDoneButtonState()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func switcherTapped(_ sender: UISwitch) {
        let day = WeekDay.allCases[sender.tag]
        if sender.isOn {
            selectedDays[day] = true
            if sender.tag != 6 {
                schedule.append(sender.tag + 2)
            } else {
                schedule.append(1)
            }
        } else {
            selectedDays[day] = false
            if sender.tag != 6 {
                schedule.removeAll(where: { $0 == sender.tag + 2 })
            } else {
                schedule.removeAll(where: { $0 == 1 })
            }
        }
    }
    
    private func updateDoneButtonState() {
        if !schedule.isEmpty {
            doneButton.isEnabled = true
            doneButton.backgroundColor = .trBlack
        } else {
            doneButton.isEnabled = false
            doneButton.backgroundColor = .trGray
        }
    }
    
    @objc private func doneButtonTapped() {
        delegate?.updateScheduleSelection(with: selectedDays, schedule: schedule)
        dismiss(animated: true)
    }
}

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ScheduleTableViewCell.reuseIdentifier, for: indexPath) as? ScheduleTableViewCell else { return UITableViewCell() }
        
        let day = WeekDay.allCases[indexPath.row].long
        cell.config(with: day, schedule: schedule, indexPath: indexPath)
        cell.switcher.addTarget(self, action: #selector(switcherTapped(_:)), for: .valueChanged)
        
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cellCount = tableView.numberOfRows(inSection: indexPath.section)
        cell.setCustomStyle(indexPath: indexPath, cellCount: cellCount)
    }
}

extension ScheduleViewController: SettingViewsProtocol {
    func setupView() {
        title = Constants.schedule
        view.backgroundColor = .trWhite
        
        setupTableView()
        
        view.addSubviews(scrollView)
        scrollView.addSubviews(contentView)
        contentView.addSubviews(tableView, doneButton)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
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
            contentView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor),
            
            tableView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            doneButton.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 24),
            doneButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}
