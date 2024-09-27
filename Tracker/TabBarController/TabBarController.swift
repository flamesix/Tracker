import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }
    
    private func setupTabs() {
        
        let trackerVC = TrackerViewController()
        let statisticVC = StatisticViewController()
        
        let trackerNVC = UINavigationController(rootViewController: trackerVC)
        let statisticNVC = UINavigationController(rootViewController: statisticVC)
        
        trackerNVC.navigationBar.prefersLargeTitles = true
        statisticNVC.navigationBar.prefersLargeTitles = true
        
        
        trackerNVC.tabBarItem = UITabBarItem(title: "Трекеры",
                                                image: UIImage(systemName: "record.circle.fill"),
                                                tag: 1)
        
        statisticNVC.tabBarItem = UITabBarItem(title: "Статистика",
                                            image: UIImage(systemName: "hare.fill"),
                                            tag: 2)
        
        setViewControllers([
            trackerNVC, statisticNVC
        ], animated: true)
    }
}
