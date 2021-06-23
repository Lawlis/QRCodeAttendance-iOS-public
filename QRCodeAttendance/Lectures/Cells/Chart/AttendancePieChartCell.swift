//
//  AttendancePieChartCell.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-10.
//

import UIKit
import Charts

struct PieChartModel: CellRepresentable, Hashable {
    var totalEvents: Int
    var completedEvents: Int
    var leftEvents: Int
    var attendancePercentage: Int
    var holeRadiusPercent: CGFloat = 0.42
    var valuePosition: PieChartDataSet.ValuePosition = .outsideSlice
    
    func cellInstance(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: AttendancePieChartCell = tableView.dequeueReusableCell()
        cell.populate(with: self)
        return cell
    }
    
    var cellHeight: CGFloat = 300
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(totalEvents)
        hasher.combine(completedEvents)
        hasher.combine(leftEvents)
        hasher.combine(attendancePercentage)
    }
}

class AttendancePieChartCell: UITableViewCell {
    
    @IBOutlet weak var pieChartView: PieChartView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pieChartView.legend.enabled = false
        pieChartView.transparentCircleRadiusPercent = 0
        pieChartView.transparentCircleColor = UIColor.clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func populate(with viewModel: PieChartModel) {
        var dataEntries: [ChartDataEntry] = []
        
        let completedEventsEntry = PieChartDataEntry(value: Double(viewModel.completedEvents), label: "Completed events")
        let totalEventsEntry = PieChartDataEntry(value: Double(viewModel.totalEvents), label: "Total events")
        let leftEventsEntry = PieChartDataEntry(value: Double(viewModel.leftEvents), label: "Left events")
        
        dataEntries.append(completedEventsEntry)
        dataEntries.append(totalEventsEntry)
        dataEntries.append(leftEventsEntry)
        
        let defaultFormat = DigitValueFormatter()
        
        let pieChartDataSet = PieChartDataSet(entries: dataEntries)
        pieChartDataSet.valueTextColor = UIColor.primaryText()
        pieChartDataSet.entryLabelColor = UIColor.primaryText()
        pieChartDataSet.xValuePosition = viewModel.valuePosition
        pieChartDataSet.valueFormatter = defaultFormat
        
        pieChartDataSet.colors = colorsOfCharts()
        
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        pieChartData.setValueFormatter(defaultFormat)
        if viewModel.attendancePercentage == 99 {
            pieChartView.centerText = "Attendance: 100%"
        } else {
            pieChartView.centerText = "Attendance: \(viewModel.attendancePercentage)%"
        }
        pieChartView.data = pieChartData
        pieChartView.holeRadiusPercent = viewModel.holeRadiusPercent

        pieChartView.animate(xAxisDuration: 1, easingOption: .easeInCirc)
    }
    
    private func colorsOfCharts() -> [UIColor] {
        var colors: [UIColor] = []
        let green = UIColor(red: 66 / 255, green: 255 / 255, blue: 201 / 255, alpha: 1)
        let kindaWhite = UIColor(red: 176 / 255, green: 254 / 255, blue: 254 / 255, alpha: 1)
        let darkBlue = UIColor(red: 47 / 255, green: 148 / 255, blue: 180 / 255, alpha: 1)
        
        colors.append(green)
        colors.append(kindaWhite)
        colors.append(darkBlue)
        return colors
    }
}

extension UIColor {
    public convenience init(hex: String) {
        let red, green, blue, alpha: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    red = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    green = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    blue = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    alpha = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
            }
        }

        self.init(red: 0, green: 0, blue: 0, alpha: 1)
    }
}

class DigitValueFormatter: NSObject, ValueFormatter {

    func stringForValue(_ value: Double,
                        entry: ChartDataEntry,
                        dataSetIndex: Int,
                        viewPortHandler: ViewPortHandler?) -> String {
        let valueWithoutDecimalPart = String(format: "%.0f", value)
        return "\(valueWithoutDecimalPart)"
    }
}
