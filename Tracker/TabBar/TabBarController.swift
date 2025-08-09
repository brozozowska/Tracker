//
//  TabBarController.swift
//  Tracker
//
//  Created by Сергей Розов on 09.08.2025.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        let trackersViewController = TrackersViewController()
        let trackersNav = UINavigationController(rootViewController: trackersViewController)
        trackersNav.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "smallcircle.filled.circle.fill"),
            selectedImage: UIImage(systemName: "smallcircle.filled.circle.fill")
        )
        
        let statsViewController = StatisticsViewController()
        let statsNav = UINavigationController(rootViewController: statsViewController)
        statsNav.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: UIImage(systemName: "hare.fill")
        )
        
        viewControllers = [trackersNav, statsNav]
    }
}
