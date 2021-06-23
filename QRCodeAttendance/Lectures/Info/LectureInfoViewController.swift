//
//  LectureInfoViewController.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-11.
//

import UIKit

class LectureInfoViewController: UITableViewController {
    
    var lecture: Lecture!
    
    private lazy var dataSource = LectureInfoDataSource(tableView: tableView)

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.lecture = lecture
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        dataSource.updateTableView()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return dataSource.itemIdentifier(for: indexPath)?.cellHeight ?? 0
    }
}
