//
//  AnyCellRepresentable.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-12.
//

import Foundation
import UIKit

struct AnyCellRepresentable: CellRepresentable {

    // MARK: - State

    var wrapped: CellRepresentable
    var wrappedHashValue: Int

    var cellHeight: CGFloat {
        return wrapped.cellHeight
    }
    
    var isSelectable: Bool {
        return wrapped.isSelectable
    }

    // MARK: - Init

    init<Type: CellRepresentable & Hashable>(for wrapped: Type) {
        self.wrapped = wrapped
        self.wrappedHashValue = wrapped.hashValue
    }

    // MARK: - Factory

    func cellInstance(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        return wrapped.cellInstance(in: tableView, at: indexPath)
    }

}

extension AnyCellRepresentable: Hashable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedHashValue)
    }

    static func ==(lhs: AnyCellRepresentable, rhs: AnyCellRepresentable) -> Bool {
        return lhs.wrappedHashValue == rhs.wrappedHashValue
    }

}
