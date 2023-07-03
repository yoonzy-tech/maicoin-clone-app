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
    }
}
