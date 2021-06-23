//
//  LecturesDataModel.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-05.
//

import Foundation
import Moya

protocol LecturesDelegate: AnyObject {
    func didUpdate(_ model: LecturesDataModel)
}

class LecturesDataModel: Networkable {
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
}
