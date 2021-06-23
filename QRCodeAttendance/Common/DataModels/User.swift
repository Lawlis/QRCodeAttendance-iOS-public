//
//  User.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-03-07.
//

import Foundation

struct User: Encodable {
    let id: String
    var name: String
    var surname: String
    var email: String
    var role: Role
    var group: Group?
    var faculty: Faculty?
    var attendance: Attendance?
    
    struct BaseInformation: Codable, Hashable {
        init(user: User) {
            self.id = user.id
            self.name = user.name
            self.surname = user.surname
            self.group = user.group
            self.role = user.role
        }
        
        let id: String
        var name: String
        var surname: String
        var group: Group?
        var role: Role?
    }
    
    struct AttendedStudent: Codable, Hashable {
        let id: String
        var name: String
        var surname: String
        var group: Group?
        var role: Role?
        var checkInDatestamp: String?
        var checkOutDatestamp: String?
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case surname
        case email
        case role
        case group
        case faculty
        case attendance
    }
}

extension User: Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
}

extension User: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(surname)
        hasher.combine(email)
        hasher.combine(role)
        hasher.combine(group)
        hasher.combine(faculty)
        hasher.combine(attendance)
    }
}

extension User: SearchItem, CustomStringConvertible {
    func matchesSearchQuery(_ query: String) -> Bool {
        return name.lowercased().contains(query.lowercased()) || surname.lowercased().contains(query.lowercased())
    }
    
    var description: String {
        if let group = group {
            return group.name + " " + name + " " + surname
        }
        return name + " " + surname
    }
}

extension User.BaseInformation: SearchItem, CustomStringConvertible {
    func matchesSearchQuery(_ query: String) -> Bool {
        return name.lowercased().contains(query.lowercased()) || surname.lowercased().contains(query.lowercased())
    }
    
    var description: String {
        return name + " " + surname
    }
}

extension User: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let id = try container.decode(String.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let surname = try container.decode(String.self, forKey: .surname)
        let email = try container.decode(String.self, forKey: .email)
        let role = try container.decode(Role.self, forKey: .role)
        let group = try container.decodeIfPresent(Group.self, forKey: .group)
        let faculty = try container.decodeIfPresent(Faculty.self, forKey: .faculty)
        let attendance = try container.decodeIfPresent(Attendance.self, forKey: .attendance)
        
        self.init(id: id,
                  name: name,
                  surname: surname,
                  email: email,
                  role: role,
                  group: group,
                  faculty: faculty,
                  attendance: attendance)
    }
}

enum Role: String, Codable {
    case student = "ROLE_STUDENT"
    case lecturer = "ROLE_LECTOR"
    case admin = "ROLE_ADMIN"
    
    var isLecturer: Bool {
        return self == .lecturer || self == .admin
    }
}

struct CreateUserRequest: Encodable {
    let name: String
    let surname: String
}
