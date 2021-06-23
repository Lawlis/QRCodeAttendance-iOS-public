//
//  Lecture.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-03-07.
//

import Foundation

struct Lecture: Codable, Hashable {
    let id: Int
    var name: String
    var assignedStudents: [User.BaseInformation]
    var assignedLectors: [User.BaseInformation]
    var events: [Event]
    var faculty: Faculty
    var attendance: Attendance?
    
    struct Create: Codable {
        let name: String
        let assignedStudents: [User.BaseInformation]
        let assignedLectors: [User.BaseInformation]
        let faculty: Faculty
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(assignedStudents)
        hasher.combine(assignedLectors)
        hasher.combine(events)
        hasher.combine(faculty)
        hasher.combine(attendance)
    }
}

extension Lecture: Equatable {
    static func == (lhs: Lecture, rhs: Lecture) -> Bool {
        lhs.id == rhs.id
    }
}

extension Lecture: SearchItem, CustomStringConvertible {
    func matchesSearchQuery(_ query: String) -> Bool {
        return name.lowercased().contains(query.lowercased())
    }
    
    var description: String {
        return name
    }
}
