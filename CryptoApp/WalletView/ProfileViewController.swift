//
//  ProfileViewController.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/6.
//

import UIKit

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var verificationButton: UIButton!
    
    @IBOutlet weak var uidLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "會員"
        verificationButton.layer.shadowColor = UIColor.darkGray.cgColor
        verificationButton.layer.shadowOpacity = 0.3
        verificationButton.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        verificationButton.layer.shadowRadius = 5
        verificationButton.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getUidVerifyStatus()
    }
    
    private func getUidVerifyStatus() {
        guard let profile = CoinbaseService.shared.fetchUserProfileNew() else {
            print("No profile data")
            return
        }
        uidLabel.text = "UID: \(profile.userId)"
        verificationButton.setTitle(profile.active ? "身分驗證成功" : "身分驗證失敗", for: .normal)
        verificationButton.setTitleColor(profile.active ? UIColor(hexString: .green): UIColor(hexString: .red), for: .normal)
    }
}
