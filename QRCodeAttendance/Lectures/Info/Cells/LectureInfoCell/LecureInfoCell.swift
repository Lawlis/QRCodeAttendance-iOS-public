//
//  LecureInfoCell.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-11.
//

import UIKit

struct LectureInfoCellModel: CellRepresentable, Hashable {
    var name: String
    var facultyTitle: String
    
    var cellHeight: CGFloat = 150
    
    func cellInstance(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: LecureInfoCell = tableView.dequeueReusableCell()
        cell.populate(with: self)
        return cell
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(facultyTitle)
    }
}

class LecureInfoCell: UITableViewCell {
    @IBOutlet weak var lectureTitleLabel: UILabel!
    @IBOutlet weak var facultyTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func populate(with viewModel: LectureInfoCellModel) {
        lectureTitleLabel.text = viewModel.name
        facultyTitleLabel.text = "Faculty: \(viewModel.facultyTitle)"
    }
}
