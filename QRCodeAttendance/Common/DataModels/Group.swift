//
//  Group.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-16.
//

import Foundation

struct Group: Codable {
    let id: Int
    var name: String
    
    struct Create: Encodable {
        var name: String
        var assignedStudents: [User.BaseInformation]
    }
    
    struct Inclusive: Codable {
        let id: Int
        var name: String
        var assignedStudents: [User.BaseInformation]
    }
}

extension Group: SearchItem, CustomStringConvertible {
    func matchesSearchQuery(_ query: String) -> Bool {
        name.lowercased().contains(query.lowercased())
    }
    
    var description: String {
        name
    }
}

extension Group.Inclusive: SearchItem, CustomStringConvertible {
    func matchesSearchQuery(_ query: String) -> Bool {
        name.lowercased().contains(query.lowercased())
    }
    
    var description: String {
        name
    }
}

extension Group: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}

extension Group.Inclusive: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(assignedStudents)
    }
}
