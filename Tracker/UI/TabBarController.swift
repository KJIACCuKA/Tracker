import UIKit

final class TabBarController: UITabBarController {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let trackerViewController = UINavigationController(rootViewController: TrackersViewController())
        trackerViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.trackers", comment: ""),
            image: UIImage(named: "tab_tracker_active"),
            selectedImage: nil
        )
        
        let statisticViewController = StatisticViewController()
        statisticViewController.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab.statistics", comment: ""),
            image: UIImage(named: "tab_statistic_inactive"),
            selectedImage: nil
        )
        
        viewControllers = [trackerViewController, statisticViewController]
    }
}