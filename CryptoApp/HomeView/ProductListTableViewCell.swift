//
//  ProductListTableViewCell.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/6/28.
//

import UIKit
import DGCharts

class ProductListTableViewCell: UITableViewCell, ChartViewDelegate {
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var coinIconImageView: UIImageView!
    @IBOutlet weak var coinNameLabel: UILabel!
    @IBOutlet weak var coinFullNameLabel: UILabel!
    @IBOutlet weak var coinPriceLabel: UILabel!
    @IBOutlet weak var fluctRateLabel: UILabel!
    
    var coinCode: String = "" {
        didSet {
            coinIconImageView.image = UIImage(named: coinCode)
            coinNameLabel.text = coinCode
            coinFullNameLabel.text = coinCodeToZHTWName[coinCode]
        }
    }
    
    var price: Double = 0 {
        didSet {
            coinPriceLabel.text = price.formatMarketDataString()
        }
    }
    
    var rate: Double = 0 {
        didSet {
            fluctRateLabel.text = "\(rate > 0 ? "+" : "")\(rate.formatMarketDataString())%"
            fluctRateLabel.textColor = rate > 0 ? UIColor(hexString: .green) : UIColor(hexString: .red)
            setupChartView(lineColor: UIColor(hexString: rate > 0 ? .green : .red))
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setupChartView(lineColor: UIColor) {
        lineChartView.delegate = self
        lineChartView.chartDescription.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.doubleTapToZoomEnabled = false
        
        var values: [Double] = []
        var valueArray: [Double] = []
        for _ in 1...30 {
            let randomValue = Double.random(in: 23...25)
            valueArray.append(randomValue)
        }
        var dataEntries: [ChartDataEntry] = []
        if valueArray.count >= 10 {
            while values.count < 10 {
                let randomIndex = Int.random(in: 0..<valueArray.count)
                let randomValue = valueArray[randomIndex]
                values.append(randomValue)
            }
        }
        
        for i in 0..<values.count {
            let formattedValue = String(format: "%.2f", values[i])
            let dataEntry = ChartDataEntry(x: Double(i), y: Double(formattedValue) ?? 0)
            dataEntries.append(dataEntry)
        }
        
        let dataSet = LineChartDataSet(entries: dataEntries)
        dataSet.mode = .cubicBezier
        dataSet.colors = [lineColor]
        dataSet.drawCirclesEnabled = false
        dataSet.drawValuesEnabled = false
        dataSet.highlightEnabled = false
        dataSet.lineWidth = 1.3
        
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        lineChartView.notifyDataSetChanged()
    }
}
