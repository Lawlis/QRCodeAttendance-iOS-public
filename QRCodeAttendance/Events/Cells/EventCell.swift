//
//  EventCell.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-04-10.
//

import UIKit

struct EventCellModel: CellRepresentable, Hashable {
    let id = UUID()
    
    static func == (lhs: EventCellModel, rhs: EventCellModel) -> Bool {
        return lhs.title == rhs.title &&
            lhs.startTimeString == rhs.startTimeString &&
            lhs.endTimeString == rhs.endTimeString &&
            lhs.id == rhs.id
    }
    
    let title: String
    var startTimeString: String
    var endTimeString: String
    let parentLecture: SmallLecture
    let checkOutRequired: Bool
    let actionsLimit: Int
    let shareEnabled: Bool
    let checkedIn: Bool
    let checkedOut: Bool
    let hideAllButtons: Bool
        
    var onCheckInTapped: (() -> Void)?
    var onCheckOutTapped: (() -> Void)?
    var onCheckInColleagueTapped: (() -> Void)?
    var onCheckOutColleagueTapped: (() -> Void)?
    
    func cellInstance(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: EventCell = tableView.dequeueReusableCell()
        cell.configure(with: self)
        return cell
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(startTimeString)
        hasher.combine(endTimeString)
        hasher.combine(parentLecture)
        hasher.combine(checkOutRequired)
        hasher.combine(actionsLimit)
        hasher.combine(shareEnabled)
        hasher.combine(checkedIn)
    }
}

class EventCell: UITableViewCell {
    @IBOutlet weak var eventImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var checkInBtn: SecondaryButton!
    @IBOutlet weak var checkOutBtn: SecondaryButton!
    @IBOutlet weak var checkInColleagueBtn: SecondaryButton!
    @IBOutlet weak var checkOutColleagueBtn: SecondaryButton!
    
    var onCheckInTapped: (() -> Void)?
    var onCheckOutTapped: (() -> Void)?
    var onCheckInColleagueTapped: (() -> Void)?
    var onCheckOutColleagueTapped: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        eventImageView.image = UIImage(named: "whiteboard")
        checkInBtn.isHidden = true
        checkOutBtn.isHidden = true
        checkInColleagueBtn.isHidden = true
        checkOutColleagueBtn.isHidden = true
    }
    
    func configure(with viewModel: EventCellModel) {
        onCheckInTapped = viewModel.onCheckInTapped
        onCheckOutTapped = viewModel.onCheckOutTapped
        onCheckInColleagueTapped = viewModel.onCheckInColleagueTapped
        onCheckOutColleagueTapped = viewModel.onCheckOutColleagueTapped
        
        titleLabel.text = viewModel.title
        startDateLabel.text = viewModel.startTimeString
        endDateLabel.text = viewModel.endTimeString
        
        if viewModel.hideAllButtons {
            checkInBtn.isHidden = true
            checkOutBtn.isHidden = true
            checkInColleagueBtn.isHidden = true
            checkOutColleagueBtn.isHidden = true
            return
        }
        
        if viewModel.checkedIn {
            checkInBtn.isHidden = true
            if viewModel.checkOutRequired && !viewModel.checkedOut {
                eventImageView.image = UIImage(systemName: "checkmark.circle")
                checkOutBtn.isHidden = false
            } else {
                eventImageView.image = UIImage(systemName: "checkmark.circle.fill")
            }
            
            if viewModel.shareEnabled {
                checkInColleagueBtn.isHidden = false
                if viewModel.checkOutRequired && !viewModel.checkedOut {
                    checkOutColleagueBtn.isHidden = false
                }
            }
        } else {
            checkInBtn.isHidden = false
        }
    }
    
    @IBAction func checkInButtonPressed(_ sender: Any) {
        onCheckInTapped?()
    }
    
    @IBAction func checkOutButtonPressed(_ sender: Any) {
        onCheckOutTapped?()
    }
    
    @IBAction func checkInColleagueTapped(_ sender: Any) {
        onCheckInColleagueTapped?()
    }
    
    @IBAction func checkOutColleagueTapped(_ sender: Any) {
        onCheckOutColleagueTapped?()
    }
}
