//
//  Attendance.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-05-10.
//

import Foundation

struct Attendance: Codable, Hashable {
    var totalEvents: Int
    var completedEvents: Int
    var leftEvents: Int
    var attendancePercentage: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(leftEvents)
        hasher.combine(completedEvents)
        hasher.combine(leftEvents)
        hasher.combine(attendancePercentage)
    }
}
