//
//  EventDetailDataSource.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-06.
//

import UIKit

class EventDetailDataSource: UITableViewDiffableDataSource<EventDetailsSection, AnyCellRepresentable> {
    
    var event: Event!
    
    var eventAttendees: [User.AttendedStudent] = []
    
    let calendar = Calendar.current
    
    init(tableView: UITableView) {
        tableView.registerCellNib(withType: EventAttendeeCell.self)
        super.init(tableView: tableView, cellProvider: { (tableView, indexPath, row) -> UITableViewCell? in
            return row.cellInstance(in: tableView, at: indexPath)
        })
        defaultRowAnimation = .automatic
    }
    
    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<EventDetailsSection, AnyCellRepresentable>()
        
        let attendableRows = self.attendableStudents()
        let attendeesRows = self.attendeesRows()
        
        if !attendableRows.isEmpty {
            snapshot.appendSections([.attendableStudents])
            snapshot.appendItems(attendableRows)
        }
        
        if !eventAttendees.isEmpty {
            snapshot.appendSections([.attendedStudents])
            snapshot.appendItems(attendeesRows)
        }
        
        apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    private func attendableStudents() -> [AnyCellRepresentable] {
        event.attendableStudents.map { user -> AnyCellRepresentable in
            if let group = user.group {
                let viewModel = EventAttendeeConfiguration(name: "👨‍💼 \(group.name) \(user.name) \(user.surname)")
                return AnyCellRepresentable(for: viewModel)
            } else {
                let viewModel = EventAttendeeConfiguration(name: "👨‍💼 \(user.name) \(user.surname)")
                return AnyCellRepresentable(for: viewModel)
            }
        }
    }
    
    private func attendeesRows() -> [AnyCellRepresentable] {
        eventAttendees.map { user -> AnyCellRepresentable in
            guard var checkInDate = DateTools.timeStampFormatter.date(from: user.checkInDatestamp ?? "") else {
                fatalError()
            }
            checkInDate = calendar.date(byAdding: .hour, value: 3, to: checkInDate) ?? Date()
            var checkOutString: String?
            if var checkOutDate = DateTools.timeStampFormatter.date(from: user.checkOutDatestamp ?? "") {
                checkOutDate = calendar.date(byAdding: .hour, value: 3, to: checkOutDate) ?? Date()
                checkOutString = DateTools.dateFormatter.string(from: checkOutDate)
            }
            if let group = user.group {
                let viewModel = EventAttendeeConfiguration(name: "🧑‍🎓 \(group.name) \(user.name) \(user.surname)",
                                                           checkedInAt: DateTools.dateFormatter.string(from: checkInDate),
                                                           checkedOutAt: checkOutString)
                return AnyCellRepresentable(for: viewModel)
            } else {
                let viewModel = EventAttendeeConfiguration(name: "🧑‍🎓 \(user.name) \(user.surname)",
                                                           checkedInAt: DateTools.dateFormatter.string(from: checkInDate),
                                                           checkedOutAt: checkOutString)
                return AnyCellRepresentable(for: viewModel)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Students that should attend this lecture"
        } else {
            return "Students that have attended this lecture"
        }
    }
}
