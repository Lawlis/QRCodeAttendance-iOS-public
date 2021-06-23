//
//  LecturesDataModel.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-21.
//

import Foundation
import Moya
import UIKit

protocol LecturesNetworkable: Networkable {
    func getAttendableLectures(byUserId id: String, completion: @escaping (Result<[Lecture], Error>) -> Void)
}

enum LecturesSection: CaseIterable {
    case first
}

final class LecturesDataSource: UITableViewDiffableDataSource<LecturesSection, AnyCellRepresentable>, Networkable, UITableViewDelegate {
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    var attendance: Attendance?
    var courses: [Lecture] = []
    
    private lazy var dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-mm-dd HH:mm"

        df.dateStyle = .medium
        df.timeStyle = .short
        df.doesRelativeDateFormatting = true

        return df
    }()
    
    init(tableView: UITableView) {
        tableView.registerCellNib(withType: AttendancePieChartCell.self)
        tableView.registerCellNib(withType: LectureTableViewCell.self)
        super.init(tableView: tableView, cellProvider: { (tableView, indexPath, row) -> UITableViewCell? in
            return row.cellInstance(in: tableView, at: indexPath)
        })
        defaultRowAnimation = .automatic
    }
    
    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<LecturesSection, AnyCellRepresentable>()
        snapshot.appendSections([.first])

        if let attendance = attendance,
           attendance.totalEvents > 0 {
            snapshot.appendItems([attendancePieChartRow(attendance: attendance)])
        }
                
        let coursesRows = self.coursesRows()
        
        if !courses.isEmpty {
            snapshot.appendItems(coursesRows)
        }
        
        apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func coursesRows() -> [AnyCellRepresentable] {
        let rows = courses.sorted(by: { $0.id < $1.id })
            .map { (course) -> AnyCellRepresentable in
                var nextEvent: String?
                if let earliestOccuringEvent = course.events.sorted(by: { $0.startDate < $1.endDate }).first {
                    let now = Date()
                    if earliestOccuringEvent.startDate < now {
                        nextEvent = "Last event: " + dateFormatter.string(from: earliestOccuringEvent.startDate)
                    } else {
                        nextEvent = "Upcoming event: " + dateFormatter.string(from: earliestOccuringEvent.startDate)
                    }
                }
                
                let viewModel = LectureCellViewModel(title: course.name, nextEvent: nextEvent, faculty: course.faculty.name)
                return AnyCellRepresentable(for: viewModel)
            }

        return rows
    }
    
    func attendancePieChartRow(attendance: Attendance) -> AnyCellRepresentable {
        let viewModel = PieChartModel(
            totalEvents: attendance.totalEvents,
            completedEvents: attendance.completedEvents,
            leftEvents: attendance.leftEvents,
            attendancePercentage: attendance.attendancePercentage,
            valuePosition: .insideSlice
        )
        return AnyCellRepresentable(for: viewModel)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if UserService.shared.currentUser?.role.isLecturer ?? false {
            return true
        }
        return false
    }
}
