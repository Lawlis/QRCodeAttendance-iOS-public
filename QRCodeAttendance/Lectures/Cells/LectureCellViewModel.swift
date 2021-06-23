//
//  CousesCellModel.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-12.
//

import UIKit

struct LectureCellViewModel: CellRepresentable, Identifiable {
    var id: UUID = UUID()
    var title: String
    var nextEvent: String?
    var faculty: String?
    
    func cellInstance(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: LectureTableViewCell = tableView.dequeueReusableCell()
        cell.configure(with: self)
        return cell
    }
}

extension LectureCellViewModel: Hashable {
    static func ==(lhs: LectureCellViewModel, rhs: LectureCellViewModel) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(nextEvent)
        hasher.combine(faculty)
    }
}
