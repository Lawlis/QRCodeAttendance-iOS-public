//
//  Faculty.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-16.
//

import Foundation

struct Faculty: Codable {
    let id: Int
    let name: String
}

extension Faculty: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
    }
}
