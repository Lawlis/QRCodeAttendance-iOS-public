//
//  StudentCell.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-11.
//

import UIKit

struct StudentCellViewModel: CellRepresentable, Hashable {
    var name: String
    var surname: String
    var group: String?
    
    func cellInstance(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: StudentCell = tableView.dequeueReusableCell()
        cell.populate(with: self)
        return cell
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(surname)
        hasher.combine(group)
    }
    
}

class StudentCell: UITableViewCell {

    @IBOutlet weak var studentTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populate(with viewModel: StudentCellViewModel) {
        studentTitleLabel.text = "🧑‍🎓 \(viewModel.name) \(viewModel.surname) \(viewModel.group ?? "")"
    }
    
}
