//
//  LectureTableViewCell.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-12.
//

import UIKit

class LectureTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextEventDateLabel: UILabel!
    @IBOutlet weak var facultyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with viewModel: LectureCellViewModel) {
        titleLabel.text = "course_title".localized + " " + viewModel.title
        if let nextEventString = viewModel.nextEvent {
            nextEventDateLabel.text = nextEventString
        }
        if let faculty = viewModel.faculty {
            facultyLabel.text = "course_faculty".localized + " " + faculty
        }
    }
}
