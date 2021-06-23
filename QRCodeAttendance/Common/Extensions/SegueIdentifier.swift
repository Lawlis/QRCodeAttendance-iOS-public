//
//  SegueIdentifier.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-02.
//

import Foundation

struct SegueIdentifier: RawRepresentable {
    var rawValue: String
}

extension SegueIdentifier {
    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

extension SegueIdentifier: Equatable {
    static func ==(lhs: SegueIdentifier, rhs: SegueIdentifier) -> Bool {
        return lhs.rawValue == rhs.rawValue
    }
}
