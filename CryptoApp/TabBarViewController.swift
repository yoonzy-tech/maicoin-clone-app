//
//  TabBarViewController.swift
//  
//
//  Created by Ruby Chew on 2023/6/30.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.backgroundColor = UIColor.white
         tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(hexString: .red)]
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(hexString: .red)
        self.tabBar.standardAppearance = tabBarAppearance
        self.tabBar.scrollEdgeAppearance = tabBarAppearance
        
        // configureTabBar()
    }
    
//    func configureTabBar() {
//           let viewController1 = UIViewController()
//           let viewController2 = UIViewController()
//           let viewController3 = UIViewController()
//
//           viewController1.tabBarItem = UITabBarItem(title: "Tab 1", image: UIImage(named: "tab1_icon"), selectedImage: UIImage(named: "tab1_selected_icon"))
//           viewController2.tabBarItem = UITabBarItem(title: "Tab 2", image: UIImage(named: "tab2_icon"), selectedImage: UIImage(named: "tab2_selected_icon"))
//           viewController3.tabBarItem = UITabBarItem(title: "Tab 3", image: UIImage(named: "tab3_icon"), selectedImage: UIImage(named: "tab3_selected_icon"))
//
//           viewControllers = [viewController1, viewController2, viewController3]
//           tabBar.tintColor = UIColor.red
//       }
}
