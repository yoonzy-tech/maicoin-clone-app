//
//  FullHistoryViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/6.
//

import UIKit

class FullHistoryViewController: UIViewController {

    var histories: [Order] = []
    
    var filteredCoin: String = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "資產紀錄"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "HistoryTableViewCell",
                                 bundle: nil),
                           forCellReuseIdentifier: "HistoryTableViewCell")
        
    }
    
    @IBAction func openFilterSheet(_ sender: Any) {
        if let filterOptionVC = storyboard?.instantiateViewController(withIdentifier: "FilterOptionViewController"),
           let sheetPresentationController = filterOptionVC.sheetPresentationController {
            sheetPresentationController.detents = [.medium()]
            sheetPresentationController.prefersGrabberVisible = true
            present(filterOptionVC, animated: true, completion: nil)
        }
    }
    
    func getHistorty() {
        // check if filtered coin is not empty, if not then filtered that coin
        
        // get the first 100 transactions in the past 6 months
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension FullHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        histories.count
        5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "HistoryTableViewCell", for: indexPath) as? HistoryTableViewCell
        else { fatalError("Unable to generate Table View Cell") }
        
        return cell
    }
}

extension FullHistoryViewController: FilterDelegate {
    func didSelectCoin(coinName: String) {
        self.filteredCoin = coinName
    }
}
