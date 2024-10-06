import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func updateScheduleSelection(with selectedDays: [WeekDay: Bool], schedule: [Int])
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let doneButton = TrackerButton(Constants.done, .trGray, .trWhite)
    private let tableView = TrackerTableView()
    
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
        
        let day = WeekDay.allCases[indexPath.row].rawValue
        cell.config(with: day, schedule: schedule, indexPath: indexPath)
        cell.switcher.addTarget(self, action: #selector(switcherTapped(_:)), for: .valueChanged)
        
        return cell
    }
}

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

extension ScheduleViewController: SettingViewsProtocol {
    func setupView() {
        title = Constants.schedule
        view.backgroundColor = .trWhite
        
        setupTableView()
        
        view.addSubviews(tableView, doneButton)
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        addConstraints()
        
    }
    func addConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 525),
            
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
}
