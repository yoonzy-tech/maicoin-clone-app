//
//  ChartTableViewCell.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import UIKit
import DGCharts

class ChartTableViewCell: UITableViewCell, ChartViewDelegate {
    
    weak var tableView: UITableView?
    
    let viewModel = MarketChartViewModel()

    var minXIndex: Double!
    var maxXIndex: Double!
    
    var data: LineChartData!
    var dataSet: LineChartDataSet!
    var dataEntries: [ChartDataEntry] = []
    
    var dayArray: [Double] = []
    
    var weekArray: [Double] = []
    
    var monthArray: [Double] = []
    
    var threeMonthArray: [Double] = []
    
    var yearArray: [Double] = []
  
    var allArray: [Double] = []
    
    var dayTimeArray: [Double] = []
    
    var weekTimeArray: [Double] = []
    
    var monthTimeArray: [Double] = []
    
    var threeMonthTimeArray: [Double] = []
    
    var yearTimeArray: [Double] = []
  
    var allTimeArray: [Double] = []

    @IBOutlet weak var historyTimeLabel: UILabel!
    @IBOutlet weak var realtimeSellPriceLabel: UILabel!
    @IBOutlet weak var realtimeBuyPriceLabel: UILabel!
    @IBOutlet weak var historyAveragePriceView: UIView!
    @IBOutlet weak var historyAveragePriceLabel: UILabel!
    @IBOutlet weak var lineChartView: LineChartView!
    
    @IBOutlet weak var dayButton: UIButton!
    @IBOutlet weak var weekButton: UIButton!
    @IBOutlet weak var monthButton: UIButton!
    @IBOutlet weak var threeMonthButton: UIButton!
    @IBOutlet weak var yearButton: UIButton!
    @IBOutlet weak var allButton: UIButton!
    
    @IBOutlet weak var dayView: UIView!
    @IBOutlet weak var weekView: UIView!
    @IBOutlet weak var monthView: UIView!
    @IBOutlet weak var threeMonthView: UIView!
    @IBOutlet weak var yearView: UIView!
    @IBOutlet weak var allView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        historyAveragePriceView.isHidden = true
        setButton(exceptButton: dayButton, exceptView: dayView)
        lineChartView.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 20)
    }
    
    @IBAction func didDayButtonTapped(_ sender: Any) {
        setButton(exceptButton: dayButton, exceptView: dayView)
        changeChartViewData(dataArray: dayArray, timeArray: dayTimeArray)
//        viewModel.getTimeCandles(time: .day) { [weak self] extractedCandles in
//             print("🟢 Day Candles Count: \(extractedCandles.count)")
//             print("🟢 Day Candles: \(extractedCandles)")
//            self?.dayArray = extractedCandles.compactMap({ $0.averagePrice })
//        }
    }
    
    @IBAction func didWeekButtonTapped(_ sender: Any) {
        setButton(exceptButton: weekButton, exceptView: weekView)
        changeChartViewData(dataArray: weekArray, timeArray: weekTimeArray)
//        viewModel.getTimeCandles(time: .week) { [weak self] extractedCandles in
//             print("🟠 Week Candles Count: \(extractedCandles.count)")
//             print("🟠 Week Candles: \(extractedCandles)")
//            self?.weekArray = extractedCandles.compactMap({ $0.averagePrice })
//            self?.changeChartViewData(dataArray: self?.weekArray ?? [], timeArray: self?.weekTimeArray ?? [])
//        }
    }
    
    @IBAction func didMonthButtonTapped(_ sender: Any) {
        setButton(exceptButton: monthButton, exceptView: monthView)
        changeChartViewData(dataArray: monthArray, timeArray: monthTimeArray)
//        viewModel.getTimeCandles(time: .month) { [weak self] extractedCandles in
//             print("🟡 1 Month Candles Count: \(extractedCandles.count)")
//             print("🟡 1 Month Candles: \(extractedCandles)")
//            self?.monthArray = extractedCandles.compactMap({ $0.averagePrice })
//        }
    }
    
    @IBAction func didThreeMonthButtonTapped(_ sender: Any) {
        setButton(exceptButton: threeMonthButton, exceptView: threeMonthView)
        changeChartViewData(dataArray: threeMonthArray, timeArray: threeMonthTimeArray)
//        viewModel.getTimeCandles(time: .threeMonth) { [weak self] extractedCandles in
//             print("🔵 3 Months Candles Count: \(extractedCandles.count)")
//             print("🔵 3 Months Candles: \(extractedCandles)")
//            self?.threeMonthArray = extractedCandles.compactMap({ $0.averagePrice })
//        }
    }
    
    @IBAction func didYearButtonTapped(_ sender: Any) {
        setButton(exceptButton: yearButton, exceptView: yearView)
        changeChartViewData(dataArray: yearArray, timeArray: yearTimeArray)
//        viewModel.getYearCandles { [weak self] extractedCandles in
//             print("🟤 1 Year Candles Count: \(extractedCandles.count)")
//             print("🟤 1 Year Candles: \(extractedCandles)")
//            self?.yearArray = extractedCandles.compactMap({ $0.averagePrice })
//        }
    }
    
    @IBAction func didAllButtonTapped(_ sender: Any) {
        setButton(exceptButton: allButton, exceptView: allView)
        changeChartViewData(dataArray: allArray, timeArray: allTimeArray)
//        viewModel.getAllCandles { [weak self] extractedCandles in
//             print("🟣 All Candles Count: \(extractedCandles.count)")
//             print("🟣 All Candles: \(extractedCandles)")
//            self?.allArray = extractedCandles.compactMap({ $0.averagePrice })
//        }
    }
    
    func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        guard let lineChartView = chartView as? LineChartView else {
            return
        }
        
        historyAveragePriceView.isHidden = true
        lineChartView.data?.dataSets.forEach { dataSet in
            if dataSet is LineChartDataSet {
                lineChartView.highlightValues([])
            }
        }
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        
        let timestamp: TimeInterval = entry.x
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 8 * 60 * 60)
        let date = Date(timeIntervalSince1970: timestamp)
        let dateString = dateFormatter.string(from: date)
        historyTimeLabel.text = dateString
        historyAveragePriceLabel.text = "\(entry.y.formattedAccountingString(decimalPlaces: 0, accountFormat: true))"
        historyAveragePriceView.isHidden = false
    }
}

// MARK: Setup UI

extension ChartTableViewCell {
    func setChartView(dataArray: [Double]) {
        lineChartView.delegate = self
        lineChartView.chartDescription.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        lineChartView.animate(xAxisDuration: 1.5)
        //  lineChartView.xAxis.valueFormatter = XAxisValueFormatter(monthlyTotalAmounts: monthlyTotalAmounts)
        // 設定折線圖的數據
        changeChartViewData(dataArray: dayArray, timeArray: dayTimeArray)
    }
    private func setButton(exceptButton currentButton: UIButton, exceptView currentView: UIView) {
        let buttons: [UIButton] = [
            dayButton, weekButton, monthButton,
            threeMonthButton, yearButton, allButton
        ]
        
        let views: [UIView] = [
            dayView, weekView, monthView,
            threeMonthView, yearView, allView
        ]
        
        for button in buttons {
            if button != currentButton {
                button.setTitleColor(.darkGray, for: .normal)
                button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            } else {
                button.setTitleColor(UIColor(hexString: .red), for: .normal)
                button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
            }
        }
        
        views.forEach { view in
            view.backgroundColor = view != currentView ? UIColor.white : UIColor(hexString: .red)
        }
    }
    
    func changeChartViewData(dataArray: [Double], timeArray: [Double]) {
        lineChartView.data = nil
        lineChartView.xAxis.valueFormatter = nil
        lineChartView.marker = nil
        lineChartView.notifyDataSetChanged()
        if dataArray.isEmpty == false {
            minXIndex = timeArray[dataArray.firstIndex(of: dataArray.min() ?? 0) ?? 0]
            maxXIndex = timeArray[dataArray.firstIndex(of: dataArray.max() ?? 0) ?? 0]
        }
        dataEntries = []
        dataSet = nil
        for i in 0..<dataArray.count {
            let formattedValue = String(format: "%.2f", dataArray[i])
            let dataEntry = ChartDataEntry(x: timeArray[i], y: Double(formattedValue) ?? 0)
            dataEntries.append(dataEntry)
        }
        
        dataSet = LineChartDataSet(entries: dataEntries)
        dataSet.mode = .linear
        dataSet.drawCirclesEnabled = false
        dataSet.valueFormatter = self
        dataSet.highlightLineWidth = 1
        dataSet.highlightColor = .red
        dataSet.highlightEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.lineWidth = 1
        dataSet.colors = [UIColor.red]
        dataSet.valueColors = [UIColor.red]
        dataSet.valueFont = .systemFont(ofSize: 12)
        data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        
        if let data = lineChartView.data {
            if let lineDataSet = data.dataSets.first as? LineChartDataSet {
                let startColor = UIColor.red
                let endColor = UIColor.white
                let gradientColors = [startColor.cgColor, endColor.cgColor] as CFArray
                let colorLocations: [CGFloat] = [0.0, 1.0]
                if let gradient = CGGradient(colorsSpace: nil, colors: gradientColors, locations: colorLocations) {
                    lineDataSet.fill = LinearGradientFill(gradient: gradient, angle: 270)
                    lineDataSet.drawFilledEnabled = true
                }
            }
        }
        
        if let selectedEntry = dataEntries.first {
            let coinImage = UIImage(named: "fulldown")
            let coinMarker = ImageMarkerView(color: .clear,
                                             font: .systemFont(ofSize: 10),
                                             textColor: .white,
                                             insets: .zero,
                                             image: coinImage)
            coinMarker.refreshContent(entry: selectedEntry,
                                      highlight: Highlight(x: selectedEntry.x,
                                                           y: selectedEntry.y,
                                                           dataSetIndex: 0))
            lineChartView.marker = coinMarker
        }
        lineChartView.notifyDataSetChanged()
    }
}

extension ChartTableViewCell: ValueFormatter {
    func stringForValue(_ value: Double, entry: DGCharts.ChartDataEntry, dataSetIndex: Int, viewPortHandler: DGCharts.ViewPortHandler?) -> String {
        if entry.x == minXIndex || entry.x == maxXIndex {
            entry.icon = UIImage(named: "down")
            return "\(value)"
        } else {
            return ""
        }
    }
}

class XAxisValueFormatter: IndexAxisValueFormatter {
    var labels: [String] = []
    init(monthlyTotalAmounts: [String: Int]) {
        super.init()
        let sortedItems = monthlyTotalAmounts.sorted { $0.key < $1.key }
        labels = sortedItems.map { $0.key }
    }
    
    override func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let index = labels.indices.last(where: { value >= Double($0) }) else {
            return ""
        }
        return labels[index]
    }
}

class ImageMarkerView: MarkerView {
    private var circleImageView: UIImageView?
    private var circleImage: UIImage?
    private var imageSize: CGSize
    
    init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets, image: UIImage?) {
        self.circleImage = image
        self.imageSize = image?.size ?? CGSize.zero
        
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        
        self.backgroundColor = .clear
        
        circleImageView = UIImageView(image: circleImage)
        circleImageView?.frame.size = imageSize
        addSubview(circleImageView!)
        
        circleImageView?.center = CGPoint(x: bounds.size.width / 2,
                                          y: bounds.size.height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let offset = super.offsetForDrawing(atPoint: point)
        return offset
    }
}
