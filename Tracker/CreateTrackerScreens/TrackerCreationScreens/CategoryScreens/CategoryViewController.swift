import UIKit

protocol CategoryViewControllerDelegate: AnyObject {
    func updateCategorySelection(with category: String)
}

final class CategoryViewController: UIViewController {
    
    weak var delegate: CategoryViewControllerDelegate?
    private var viewModel: CategoryViewModel?
    
    private lazy var tableView = TrackerTableView()
    private lazy var addButton = TrackerButton(Constants.addCategory, .trBlack, .trWhite)
    private lazy var emptyLogo = TrackerEmptyLogo(frame: .zero)
    private lazy var emptyLabel = TrackerEmptyLabel(Constants.emptyCategory)
    
    private var selectedIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        
    }
    
    func initViewModel(viewModel: CategoryViewModel) {
        self.viewModel = viewModel
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel?.categoriesUpdated = { [weak self] in
            self?.updateEmptyState()
            self?.tableView.reloadData()
        }
        
        viewModel?.fetchCategories()
    }
    
    @objc private func addCategory() {
        let vc = NewCategoryViewController()
        vc.delegate = self
        present(UINavigationController(rootViewController: vc), animated: true)
    }
}

extension CategoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.categoriesCount() ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryScheduleTableViewCell.reuseIdentifier, for: indexPath) as? CategoryScheduleTableViewCell else { return UITableViewCell() }
        let category = viewModel?.category(at: indexPath.row) ?? ""
        cell.configureCategory(category: category, selectedCategory: viewModel?.selectedCategory ?? "")
        return cell
    }
}

extension CategoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel?.selectCategory(at: indexPath.row)
        delegate?.updateCategorySelection(with: viewModel?.selectedCategory ?? "")
        
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
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { actions in
            return UIMenu(children: [
                UIAction(title: Constants.edit) { _ in
                    print(Constants.edit)
                },
                UIAction(title: Constants.delete, attributes: .destructive) { [weak self] _ in
                    guard let self else { return }
                    TrackerAlert.showAlert(on: self, alertTitle: Constants.deleteCategory) { [weak self] in
                        self?.deleteCategory(at: indexPath)
                    }
                }
            ])
        }
    }
    
    private func deleteCategory(at indexPath: IndexPath) {
        viewModel?.deleteCategory(at: indexPath.row)
    }
}

extension CategoryViewController: SettingViewsProtocol {
    func setupView() {
        title = Constants.category
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
        guard let viewModel else { return }
        let isEmpty = viewModel.categoriesCount() == 0
        emptyLogo.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
        tableView.isHidden = isEmpty
        let tableHeight = CGFloat(viewModel.categoriesCount() * 75)
        tableView.heightAnchor.constraint(equalToConstant: tableHeight).isActive = true
    }
}

extension CategoryViewController: NewCategoryViewControllerDelegate {
    func updateTable() {
        tableView.reloadData()
        dismiss(animated: true, completion: nil)
    }
}
