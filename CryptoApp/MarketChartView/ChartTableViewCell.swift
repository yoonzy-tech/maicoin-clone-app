//
//  ChartTableViewCell.swift
//  CryptoApp
//
//  Created by Ruby Chew on 2023/7/1.
//

import UIKit
import DGCharts

class ChartTableViewCell: UITableViewCell, ChartViewDelegate {
    
    var minXIndex: Double!
    var maxXIndex: Double!
    
    var data: LineChartData!
    var dataSet: LineChartDataSet!
    var dataEntries: [ChartDataEntry] = []
    
    var dayArray: [Double] = [24.453, 24.5434, 24.865, 25.3, 23.2344, 24.2353, 24.822, 24.1422, 23.2123, 25.2, 24.23435, 22.8, 24.122, 24.33, 23.23, 24.235, 24.8, 25.122, 25.423]
    var weekArray: [Double] = [24.45, 24.1434, 24.865, 25.3, 24.2344, 24.2353, 24.822, 24.1422, 24.2123, 25.5, 24.24435, 23.8, 24.122, 25, 23.23, 23.235, 23.8, 24.122, 25.123]
    var monthArray: [Double] = [25.45, 26.1434, 25.865, 25.3, 25.2344, 25.2353, 24.822, 24.1422, 24.2123, 25.5, 25.24435, 25.8, 26.122, 25, 25.23, 23.235, 24.8, 28.122, 25.123]
    var threeMonthArray: [Double] = [25.453, 23.5434, 24.865, 25.3, 25.2344, 24.2353, 24.822, 24.1422, 23.2123, 25.2, 24.23435, 22.8, 24.122, 24.33, 23.23, 24.235, 24.8, 25.122, 25.423]
    var yearArray: [Double] = [23.45, 24.1434, 24.865, 25.3, 24.2344, 26.2353, 24.822, 24.1422, 24.2123, 25.5, 25.24435, 26.8, 24.122, 24, 23.23, 23.235, 23.8, 29.122, 25.123]
    var allArray: [Double] = [25.45, 23.1434, 24.865, 25.3, 25.2344, 25.2353, 24.822, 24.1422, 24.2123, 25.5, 25.24435, 25.8, 28.122, 25, 25.23, 23.235, 24.8, 24.122, 25.123]
    
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
        setChartView(dataArray: dayArray)
        setButton(exceptButton: dayButton, exceptView: dayView)
        lineChartView.setViewPortOffsets(left: 0, top: 0, right: 0, bottom: 20)
    }
    
    @IBAction func didDayButtonTapped(_ sender: Any) {
        setButton(exceptButton: dayButton, exceptView: dayView)
        changeChartViewData(dataArray: weekArray)
    }
    
    @IBAction func didWeekButtonTapped(_ sender: Any) {
        setButton(exceptButton: weekButton, exceptView: weekView)
        changeChartViewData(dataArray: monthArray)
    }
    @IBAction func didMonthButtonTapped(_ sender: Any) {
        setButton(exceptButton: monthButton, exceptView: monthView)
        changeChartViewData(dataArray: threeMonthArray)
    }
    @IBAction func didThreeMonthButtonTapped(_ sender: Any) {
        setButton(exceptButton: threeMonthButton, exceptView: threeMonthView)
        changeChartViewData(dataArray: yearArray)
    }
    @IBAction func didYearButtonTapped(_ sender: Any) {
        setButton(exceptButton: yearButton, exceptView: yearView)
        changeChartViewData(dataArray: allArray)
    }
    @IBAction func didAllButtonTapped(_ sender: Any) {
        setButton(exceptButton: allButton, exceptView: allView)
        changeChartViewData(dataArray: dayArray)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
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
        historyAveragePriceLabel.text = "\(entry.y)"
        historyAveragePriceView.isHidden = false
    }
}

// MARK: Setup UI

extension ChartTableViewCell {
    private func setChartView(dataArray: [Double]) {
        lineChartView.delegate = self
        lineChartView.chartDescription.enabled = false
        lineChartView.legend.enabled = false
        lineChartView.xAxis.enabled = false
        lineChartView.leftAxis.enabled = false
        lineChartView.rightAxis.enabled = false
        lineChartView.scaleXEnabled = false
        lineChartView.scaleYEnabled = false
        lineChartView.doubleTapToZoomEnabled = false
        //  lineChartView.xAxis.valueFormatter = XAxisValueFormatter(monthlyTotalAmounts: monthlyTotalAmounts)
        // 設定折線圖的數據
        changeChartViewData(dataArray: dayArray)
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
    
    private func changeChartViewData(dataArray: [Double]) {
        lineChartView.data = nil
        lineChartView.xAxis.valueFormatter = nil
        lineChartView.marker = nil
        lineChartView.notifyDataSetChanged()
        minXIndex = Double(dataArray.firstIndex(of: dataArray.min()!)!) + 1
        maxXIndex = Double(dataArray.firstIndex(of: dataArray.max()!)!) + 1
        dataEntries = []
        dataSet = nil
        for i in 0..<dataArray.count {
            let formattedValue = String(format: "%.2f", dataArray[i])
            let dataEntry = ChartDataEntry(x: Double(i+1), y: Double(formattedValue) ?? 0)
            dataEntries.append(dataEntry)
        }
        
        dataSet = LineChartDataSet(entries: dataEntries)
        dataSet.mode = .linear
        dataSet.drawCirclesEnabled = false
        dataSet.valueFormatter = self
        dataSet.highlightLineWidth = 1.5
        dataSet.highlightColor = .red
        dataSet.highlightEnabled = true
        dataSet.drawHorizontalHighlightIndicatorEnabled = false
        dataSet.lineWidth = 1.5
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
        
        circleImageView?.center = CGPoint(x: bounds.size.width / 2, y: bounds.size.height / 2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let offset = super.offsetForDrawing(atPoint: point)
        return offset
    }
    
}
