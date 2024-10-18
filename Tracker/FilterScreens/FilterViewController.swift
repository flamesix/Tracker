import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func didSelectFilter(filter: Filters?)
}

final class FilterViewController: UIViewController {
    
    weak var delegate: FilterViewControllerDelegate?
    
    private let tableView = TrackerTableView()
    
    var selectedFilter: Filters?
    private var selectedIndexPath: IndexPath?
    
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
        let filter = Filters.allCases[indexPath.row].description
        cell.configureFilter(filter: filter, selectedFilter: selectedFilter?.description)
        return cell
    }
}

extension FilterViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let filter = Filters.allCases[indexPath.row]
        delegate?.didSelectFilter(filter: filter.description == selectedFilter?.description ? nil : filter)
        if let previousIndexPath = selectedIndexPath, previousIndexPath != indexPath {
            let previousCell = tableView.cellForRow(at: previousIndexPath)
            previousCell?.accessoryType = .none
        }
        
        let currentCell = tableView.cellForRow(at: indexPath)
        currentCell?.accessoryType = .checkmark
        
        selectedIndexPath = indexPath
        tableView.deselectRow(at: indexPath, animated: true)
        dismiss(animated: true)
    }
}

extension FilterViewController: SettingViewsProtocol {
    func setupView() {
        title = Constants.filters
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
