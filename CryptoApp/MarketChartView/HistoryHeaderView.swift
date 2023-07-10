//
//  HistoryHeaderView.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import UIKit

class HistoryHeaderView: UITableViewHeaderFooterView {

    weak var navigationController: UINavigationController?
    
    var selectedCoin: String = ""
    
    @IBAction func viewAllButton(_ sender: Any) {
        // perform segue to all history view controller
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let fullHistoryVC = storyboard
            .instantiateViewController(withIdentifier: "FullHistoryViewController") as? FullHistoryViewController else {
            return
        }
        fullHistoryVC.filteredCoin = selectedCoin
        navigationController?.pushViewController(fullHistoryVC, animated: true)
    }
}
