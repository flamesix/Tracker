import UIKit

final class FilterViewController: UIViewController {
    
    private let tableView = TrackerTableView()
    
    private enum Filters: String, CaseIterable {
        case allTrackers = "Все трекеры"
        case todayTrackers = "Трекеры на сегодня"
        case doneTrackers = "Завершенные"
        case activeTrackers = "Не завершенные"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
}

extension FilterViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Filters.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterTableViewCell.reuseIdentifier, for: indexPath) as? FilterTableViewCell else { return UITableViewCell() }
        let filter = Filters.allCases[indexPath.row].rawValue
        cell.configureFilter(filter: filter, selectedFilter: filter)
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    
}

extension FilterViewController: SettingViewsProtocol {
    func setupView() {
        title = "Фильтры"
        view.backgroundColor = .trWhite
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(FilterTableViewCell.self, forCellReuseIdentifier: FilterTableViewCell.reuseIdentifier)
        
        view.addSubviews(tableView)
        addConstraints()
    }
    
    func addConstraints() {
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: 75 * 4)
        ])
    }
}
