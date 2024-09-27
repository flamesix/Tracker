import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func updateCategorySelection(with category: String)
}

final class CategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewControllerDelegate?
    
    var selectedCategory: String = ""
    private let tableView = TrackerTableView()
    private let addButton = TrackerButton("Добавить категорию", .trBlack, .trWhite)
    private let emptyLogo = TrackerEmptyLogo(frame: .zero)
    private let emptyLabel = TrackerEmptyLabel("Привычки и события можно \n объединить по смыслу")
    
    private var selectedIndexPath: IndexPath?
    var categories: [TrackerCategory] = [] {
        didSet {
            updateEmptyState()
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    @objc private func addCategory() {
        let vc = NewCategoryViewController()
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryScheduleTableViewCell.reuseIdentifier, for: indexPath) as? CategoryScheduleTableViewCell else { return UITableViewCell() }
        let category = categories[indexPath.row].title
        cell.configureCategory(category: category, selectedCategory: selectedCategory)
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
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
        let category = categories[indexPath.row].title
        delegate?.updateCategorySelection(with: category)
        dismiss(animated: true)
    }
}

extension CategoryViewController: SettingViewsProtocol {
    func setupView() {
        title = "Категория"
        view.backgroundColor = .trWhite
        
        setupTableView()
        addButton.addTarget(self, action: #selector(addCategory), for: .touchUpInside)
        
        view.addSubviews(tableView, emptyLogo, emptyLabel, addButton)
        addConstraints()
        
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
            emptyLabel.heightAnchor.constraint(equalToConstant: 36),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.heightAnchor.constraint(equalToConstant: CGFloat(categories.count * 75)),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            addButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            addButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addButton.heightAnchor.constraint(equalToConstant: 60)
            
        ])
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    private func updateEmptyState() {
        emptyLogo.isHidden = !categories.isEmpty
        emptyLabel.isHidden = !categories.isEmpty
        tableView.isHidden = categories.isEmpty
    }
}

extension CategoryViewController: NewCategoryViewControllerDelegate {
    func updateTable() {
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
