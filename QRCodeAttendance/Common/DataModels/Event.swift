//
//  Event.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-07.
//

import Foundation

struct Event: Codable, Hashable {
    let id: Int
    let title: String
    let lecture: SmallLecture
    let startDate: Date
    let endDate: Date
    let attendableStudents: [User.BaseInformation]
    let lector: User.BaseInformation
    let actionsLimit: Int
    let shareEnabled: Bool
    let checkOutRequired: Bool
    let checkedIn: Bool
    let checkedOut: Bool
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(lecture)
        hasher.combine(startDate)
        hasher.combine(endDate)
        hasher.combine(attendableStudents)
        hasher.combine(lector)
        hasher.combine(actionsLimit)
        hasher.combine(shareEnabled)
        hasher.combine(checkOutRequired)
        hasher.combine(checkedIn)
    }
    
    struct Create: Encodable {
        var title: String
        var lecture: Lecture
        var startDate: String
        var startTime: String
        var endDate: String?
        var endTime: String
        var attendableStudents: [User.BaseInformation]
        var lector: User.BaseInformation
        var periodicity: Periodicity
        let actionsLimit: Int
        let shareEnabled: Bool
        let checkOutRequired: Bool
        
        // swiftlint:disable:next nesting
        private enum CodingKeys: String, CodingKey {
            case title
            case lecture
            case startTime
            case endTime
            case attendableStudents, lector, periodicity, startDate, endDate, actionsLimit, shareEnabled, checkOutRequired
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: Event.Create.CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(lecture, forKey: .lecture)
            try container.encode(startTime, forKey: .startTime)
            try container.encode(endTime, forKey: .endTime)
            try container.encode(attendableStudents, forKey: .attendableStudents)
            try container.encode(lector, forKey: .lector)
            try container.encode(periodicity, forKey: .periodicity)
            try container.encode(startDate, forKey: .startDate)
            try container.encode(endDate, forKey: .endDate)
            try container.encode(actionsLimit, forKey: .actionsLimit)
            try container.encode(shareEnabled, forKey: .shareEnabled)
            try container.encode(checkOutRequired, forKey: .checkOutRequired)
        }
    }
}

struct SmallLecture: Codable, Hashable, Identifiable, SearchItem, CustomStringConvertible {
    func matchesSearchQuery(_ query: String) -> Bool {
        name.lowercased().contains(query.lowercased())
    }
    
    var description: String {
        return name
    }
    
    init(lecture: Lecture) {
        self.databaseId = lecture.id
        self.name = lecture.name
    }
    
    let id = UUID()
    
    let databaseId: Int
    let name: String
    
    private enum CodingKeys: String, CodingKey {
        case databaseId = "id"
        case name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(databaseId)
        hasher.combine(name)
    }
}

enum EventType: String, Codable {
    case theory
    case practical
    case laboratory
}
