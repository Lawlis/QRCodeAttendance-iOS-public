//
//  EventsDataSource.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-09.
//

import Foundation
import UIKit

class EventsDataSource: UITableViewDiffableDataSource<EventsSection, AnyCellRepresentable> {
    
    var events: [Event] = []
    
    var onCheckInTapped: ((Event) -> Void)?
    var onCheckOutTapped: ((Event) -> Void)?
    var checkInColleagueTapped: ((Event) -> Void)?
    var checkOutColleagueTapped: ((Event) -> Void)?
    
    init(tableView: UITableView) {
        tableView.registerCellNib(withType: EventCell.self)
        super.init(tableView: tableView, cellProvider: { (tableView, indexPath, row) -> UITableViewCell? in
            return row.cellInstance(in: tableView, at: indexPath)
        })
        defaultRowAnimation = .automatic
    }
    
    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<EventsSection, AnyCellRepresentable>()
        
        let eventRows = self.eventRows()
        
        if !events.isEmpty {
            snapshot.appendSections([.first])
            snapshot.appendItems(eventRows)
        }
        
        apply(snapshot, animatingDifferences: true, completion: nil)
    }
    
    func eventRows() -> [AnyCellRepresentable] {
        let rows = events.sorted(by: { $0.startDate < $1.startDate })
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
                    hideAllButtons: UserService.shared.currentUser?.role.isLecturer ?? false,
                    onCheckInTapped: { [weak self] in
                        self?.onCheckInTapped?(event)
                    },
                    onCheckOutTapped: { [weak self] in
                        self?.onCheckOutTapped?(event)
                    },
                    onCheckInColleagueTapped: { [weak self] in
                        self?.checkInColleagueTapped?(event)
                    },
                    onCheckOutColleagueTapped: { [weak self] in
                        self?.checkOutColleagueTapped?(event)
                    })
                return AnyCellRepresentable(for: viewModel)
            }

        return rows
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if UserService.shared.currentUser?.role.isLecturer ?? false {
            return true
        }
        return false
    }
}
