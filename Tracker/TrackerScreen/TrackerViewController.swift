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
    
    private let emptyLogo: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "EmptyLogo")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.addTarget(TrackerViewController.self, action: #selector(datePickerValueChanged(_:)), for: .valueChanged)
        return picker
    }()
    
    var trackers: [Tracker] = [
        Tracker(id: UUID(), title: "Создать", color: "tr1", emoji: "😜", schedule: "5 days"),
        Tracker(id: UUID(), title: "Назначить", color: "tr2", emoji: "😀", schedule: "3 days"),
        Tracker(id: UUID(), title: "Запомнить позвонить, чтобы назначить и создать", color: "tr3", emoji: "😎", schedule: "0 days"),
    ]
    
    var currentDate: Date = Date()
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    @objc private func didTapAddButton() {
        let vc = CreateTrackerViewController()
        present(vc, animated: true)
        
    }
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy" // Формат даты
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)")
    }
    
    private func setupView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier)
        
        setupNavBar()
        
        view.backgroundColor = .trWhite
        if trackers.isEmpty {
            view.addSubviews(emptyLogo, emptyLabel)
            
            NSLayoutConstraint.activate([
                
                emptyLogo.widthAnchor.constraint(equalToConstant: 80),
                emptyLogo.heightAnchor.constraint(equalToConstant: 80),
                emptyLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
                emptyLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
                
                emptyLabel.topAnchor.constraint(equalTo: emptyLogo.bottomAnchor, constant: 8),
                emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                emptyLabel.heightAnchor.constraint(equalToConstant: 18),
                
            ])
        } else {
            view.addSubview(collectionView)
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
                collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            ])
        }
    }
    
    private func setupNavBar() {
        title = "Трекеры"
        //        navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton)), animated: true)
        navigationItem.setLeftBarButton(UIBarButtonItem(image: UIImage(named: "addButton"), style: .done, target: self, action: #selector(didTapAddButton)), animated: true)
        navigationItem.leftBarButtonItem?.tintColor = .trBlack
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }
}

extension TrackerViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCollectionViewCell.reuseIdentifier, for: indexPath) as? TrackerCollectionViewCell else { return UICollectionViewCell() }
        let tracker = trackers[indexPath.row]
//        cell.layer.borderColor = UIColor.black.cgColor
//        cell.layer.borderWidth = 3
        cell.configureCell(tracker)
        return cell
    }
}

extension TrackerViewController: UICollectionViewDelegate {
    
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
    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
//    }
}
