//
//  CellRepresentable.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-12.
//

import UIKit

protocol CellRepresentable {
    var cellHeight: CGFloat { get }
    var isSelectable: Bool { get }
    
    func cellInstance(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell
}

extension CellRepresentable {
    var cellHeight: CGFloat {
        return UITableView.automaticDimension
    }

    var isSelectable: Bool {
        return false
    }
}
