//
//  LectureInfoDataSource.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-11.
//

import UIKit

enum LectureInfoSection: String, CaseIterable {
    case lectureInfo = "Lecture info"
    case assignedStudents = "Assigned students"
    case assignedLectors = "Assigned lectors"
    case events = "Events"
}

class LectureInfoDataSource: UITableViewDiffableDataSource<LectureInfoSection, AnyCellRepresentable> {
    
    var lecture: Lecture!
    
    init(tableView: UITableView) {
        tableView.registerCellNib(withType: EventCell.self)
        tableView.registerCellNib(withType: AttendancePieChartCell.self)
        tableView.registerCellNib(withType: LecureInfoCell.self)
        tableView.registerCellNib(withType: StudentCell.self)
        tableView.registerCellNib(withType: LectorCell.self)
        super.init(tableView: tableView) { tableView, indexPath, row -> UITableViewCell? in
            return row.cellInstance(in: tableView, at: indexPath)
        }
        defaultRowAnimation = .automatic
    }
    
    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<LectureInfoSection, AnyCellRepresentable>()

        // Lecture info
        
        snapshot.appendSections([.lectureInfo])
        
        if let attendance = lecture.attendance {
            snapshot.appendItems([attendancePieChartRow(attendance: attendance)], toSection: .lectureInfo)
        }
        snapshot.appendItems([AnyCellRepresentable(for: LectureInfoCellModel(name: lecture.name, facultyTitle: lecture.faculty.name))],
                             toSection: .lectureInfo)
        
        // Assigned students
        
        let studentRows = studentRows()
        snapshot.appendSections([.assignedStudents])
        if !studentRows.isEmpty {
            snapshot.appendItems(studentRows, toSection: .assignedStudents)
        }
        
        // Assigned lectors
        
        let lectorRows = lectorRows()
        snapshot.appendSections([.assignedLectors])
        if !lectorRows.isEmpty {
            snapshot.appendItems(lectorRows, toSection: .assignedLectors)
        }
        
        // Events
        let eventRows = eventRows()
        snapshot.appendSections([.events])
        if !eventRows.isEmpty {
            snapshot.appendItems(eventRows)
        }
        
        apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func studentRows() -> [AnyCellRepresentable] {
        let rows = lecture.assignedStudents.map { user -> AnyCellRepresentable in
            let viewModel = StudentCellViewModel(name: user.name, surname: user.surname, group: user.group?.name)
            return AnyCellRepresentable(for: viewModel)
        }
        return rows
    }
    
    func lectorRows() -> [AnyCellRepresentable] {
        let rows = lecture.assignedLectors.map { user -> AnyCellRepresentable in
            let viewModel = LectorCellViewModel(name: user.name, surname: user.surname, email: "ktu@ktu.lt")
            return AnyCellRepresentable(for: viewModel)
        }
        return rows
    }
    
    func eventRows() -> [AnyCellRepresentable] {
        let rows = lecture.events.sorted(by: { $0.startDate < $1.startDate })
            .map { (event) -> AnyCellRepresentable in
                let viewModel = EventCellModel(
                    title: event.title,
                    startTimeString: DateTools.dateFormatter.string(from: event.startDate),
                    endTimeString: DateTools.dateFormatter.string(from: event.endDate),
                    parentLecture: event.lecture,
                    checkOutRequired: event.checkOutRequired,
                    actionsLimit: event.actionsLimit,
                    shareEnabled: event.shareEnabled,
                    checkedIn: event.checkedIn,
                    checkedOut: event.checkedOut,
                    hideAllButtons: true)
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
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return LectureInfoSection.allCases[section].rawValue
    }
}
