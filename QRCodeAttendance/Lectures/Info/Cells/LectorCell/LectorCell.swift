//
//  LectorCell.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-11.
//

import UIKit
import MessageUI

struct LectorCellViewModel: CellRepresentable, Hashable {
    
    var name: String
    var surname: String
    var email: String
    
    func cellInstance(in tableView: UITableView, at indexPath: IndexPath) -> UITableViewCell {
        let cell: LectorCell = tableView.dequeueReusableCell()
        cell.populate(with: self)
        return cell
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(surname)
        hasher.combine(email)
    }
}

class LectorCell: UITableViewCell, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var nameSurnameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(sendEmail))
        emailLabel.addGestureRecognizer(tapRecognizer)
    }
    
    func populate(with viewModel: LectorCellViewModel) {
        nameSurnameLabel.text = "👨‍🏫 \(viewModel.name) \(viewModel.surname)"
        emailLabel.text = viewModel.email
    }
    
    @objc
    func sendEmail() {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            guard let text = emailLabel.text else {
                return
            }
            mail.setToRecipients([text])
            mail.setMessageBody("<p>Dear lector,</p>", isHTML: true)
            window?.rootViewController?.present(mail, animated: true, completion: nil)
        }
    }
}
