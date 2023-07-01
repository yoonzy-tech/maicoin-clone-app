//
//  BannerBalanceTableViewCell.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/29.
//

import UIKit
import iCarousel

struct Banner {
    var name: String
    var urlString: String
}

class BannerBalanceTableViewCell: UITableViewCell {
    
    var hideBalance: Bool = false
    
    var accountTotalBalance: Double = 0 {
        didSet {
            accountBalanceLabel.text = "US$ \(hideBalance ? "******" :  accountTotalBalance.formatMarketDataString())"
        }
    }
    
    @IBOutlet weak var accountBalanceView: UIView!
    @IBOutlet weak var carousel: iCarousel!
    @IBOutlet weak var accountBalanceLabel: UILabel!
    @IBOutlet weak var accountBalanceButton: UIButton!
    
    @IBAction func hideAccountBalance(_ sender: Any) {
        hideBalance = !hideBalance
        accountBalanceButton.setImage(hideBalance ? UIImage(named: "eye-close") :
                                        UIImage(named: "eye-open"), for: .normal)
        accountBalanceLabel.text = "US$ \(hideBalance ? "******" :  String(accountTotalBalance.formatMarketDataString()))"
    }
    
    private var banners: [Banner] = [
        Banner(name: "banner1",
               urlString: "https://ethereum.org/zh-tw/"),
        Banner(name: "banner2",
               urlString: "https://coinmarketcap.com/zh-tw/currencies/solana/"),
        Banner(name: "banner3",
               urlString: "https://www.wantgoo.com/global/btc"),
        Banner(name: "banner4",
               urlString: "https://ethereum.org/zh-tw/")
    ]
    
    var timer: Timer?
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.currentPage = 0
        pageControl.numberOfPages = carousel.numberOfItems
        return pageControl
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCarouselView()
        setupAccountBalanceView()
        layoutPageControl()
        startBannerAutoplay()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        stopBannerAutoplay()
    }
    
    private func setupCarouselView() {
        carousel.type = .linear
        carousel.isPagingEnabled = true
        carousel.delegate = self
        carousel.dataSource = self
    }
    
    private func setupAccountBalanceView() {
        accountBalanceView.layer.cornerRadius = 5
        accountBalanceView.layer.shadowColor = UIColor.darkGray.cgColor
        accountBalanceView.layer.shadowOpacity = 0.5
        accountBalanceView.layer.shadowOffset = CGSize(width: 0, height: 1)
        accountBalanceView.layer.shadowRadius = 4
    }
    
    private func layoutPageControl() {
        self.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageControl.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
            pageControl.bottomAnchor.constraint(equalTo: accountBalanceView.topAnchor)
        ])
    }
}

extension BannerBalanceTableViewCell: iCarouselDelegate, iCarouselDataSource {
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        banners.count
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        let itemImageView = UIImageView(frame: CGRect(x: 0,
                                                      y: 0,
                                                      width: UIScreen.main.bounds.width,
                                                      height: carousel.bounds.height))
        itemImageView.image = UIImage(named: "\(banners[index].name)")
        return itemImageView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        if option == .wrap {
            return 1.0
        }
        return value
    }
    
    func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
        if let url = URL(string: banners[index].urlString) {
            UIApplication.shared.open(url, options: [:]) { success in
                if success {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    print("Failed to open URL")
                }
            }
        }
    }
    
    func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
        pageControl.currentPage = carousel.currentItemIndex
    }
    
    private func startBannerAutoplay() {
        timer = Timer.scheduledTimer(timeInterval: 3.0,
                                     target: self,
                                     selector: #selector(autoplayTimerFired),
                                     userInfo: nil,
                                     repeats: true)
    }
    
    @objc func autoplayTimerFired() {
        carousel.scrollToItem(at: carousel.currentItemIndex + 1, animated: true)
    }
    
    func stopBannerAutoplay() {
        timer?.invalidate()
        timer = nil
    }
}
