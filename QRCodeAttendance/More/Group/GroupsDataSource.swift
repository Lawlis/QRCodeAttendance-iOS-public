//
//  GroupsDataSource.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-23.
//

import Foundation
import UIKit

enum GroupSection {
    case first
}

class GroupsDataSource: UITableViewDiffableDataSource<GroupSection, Group.Inclusive> {
    
    var groups: [Group.Inclusive]!
    
    init(tableView: UITableView) {
        tableView.registerCellClass(withType: UITableViewCell.self)
        super.init(tableView: tableView, cellProvider: { (tableView, indexPath, group) -> UITableViewCell? in
            let cell: UITableViewCell = tableView.dequeueReusableCell(indexPath: indexPath)
            cell.textLabel?.text = group.name
            cell.detailTextLabel?.text = String(group.id)
            return cell
        })
        defaultRowAnimation = .automatic
    }

    func updateTableView() {
        var snapshot = NSDiffableDataSourceSnapshot<GroupSection, Group.Inclusive>()
        snapshot.appendSections([.first])

        if !self.groups.isEmpty {
            snapshot.appendItems(groups, toSection: .first)
        }

        apply(snapshot, animatingDifferences: true, completion: nil)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
}
