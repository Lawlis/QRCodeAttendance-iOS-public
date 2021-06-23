//
//  EventAttendeeCell.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-05.
//

import UIKit

struct EventAttendeeConfiguration: CellRepresentable, Hashable {
    
    var name: String?
    
    var checkedInAt: String?
    
    var checkedOutAt: String?
    
    var cellHeight: CGFloat = UITableView.automaticDimension
    
    func cellInstance(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: EventAttendeeCell = tableView.dequeueReusableCell()
        cell.configure(with: self)
        return cell
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(checkedInAt)
        hasher.combine(checkedOutAt)
    }
}

class EventAttendeeCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkedInLabel: UILabel!
    @IBOutlet weak var checkedOutLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with configuration: EventAttendeeConfiguration) {
        titleLabel.text = configuration.name
        if let checkedInAt = configuration.checkedInAt {
            checkedInLabel.isHidden = false
            checkedInLabel.text = "Checked in at: " + checkedInAt
        }
        
        if let checkedOutAt = configuration.checkedOutAt {
            checkedOutLabel.isHidden = false
            checkedOutLabel.text = "Checked out at: " + checkedOutAt
        }
    }
    
}
