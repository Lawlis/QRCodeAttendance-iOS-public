//
//  API.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-07.
//

import Moya
import Foundation

enum AttendanceAPI {
    // UserController
    case getUser(id: String)
    case createUser(name: String, surname: String)
    case getAllUsers
    case importStudents(fileURL: URL)
    
    // LecturesController
    case getLecture(id: Int)
    case getAttendableLectures(userId: String)
    case getLedLectures(userId: String)
    case postLecture(lecture: Lecture.Create)
    case editLecture(lecture: Lecture)
    case deleteLecture(id: Int)
    
    // FacultiesController
    case getAllFaculties
    
    // GroupController
    case postCreateGroup(group: Group.Create)
    case editGroup(group: Group.Inclusive)
    case getAllGroups
    case deleteGroup(id: Int)
    
    // EventController
    case postEvent(event: Event.Create)
    case getStudentEventsByDate(dateFrom: String, dateTo: String, userId: String)
    case getLectorEventsByDate(dateFrom: String, dateTo: String, userId: String)
    case getQrCode(eventId: Int)
    case postCheckIn(checkInRequest: EventCheckInRequest)
    case postCheckOut(checkOutRequest: EventCheckOutRequest)
    case checkInStudent(studentCheckInRequest: CheckInStudentRequest)
    case checkOutStudent(studentCheckOutRequest: CheckOutStudentRequest)
    case sharedCheckIn(req: EventSharedCheckIn)
    case sharedCheckOut(req: EventSharedCheckOut)
    case getAttendedStudents(eventId: Int)
    case editEvent(event: Event)
    case deleteEvent(eventId: Int)
}

extension AttendanceAPI: FirebaseAuthorizableTargetType {
    var baseURL: URL {
        guard let url = URL(string: "http://3.133.82.135:8080/api/") else { fatalError() }
        return url
    }
    
    var path: String {
        switch self {
        case .getUser(let id):
            return "users/\(id)"
        case .createUser:
            return "users"
        case .getAttendableLectures(let userId):
            return "lectures/attendableLectures/\(userId)"
        case .getAllUsers:
            return "users"
        case .postLecture:
            return "lectures"
        case .getAllFaculties:
            return "faculties"
        case .postCreateGroup:
            return "groups"
        case .getLedLectures(let userId):
            return "lectures/ledLectures/\(userId)"
        case .postEvent:
            return "events"
        case .getStudentEventsByDate:
            return "events/studentEventsByDate"
        case .getLectorEventsByDate:
            return "events/lectorEventsByDate"
        case .getQrCode:
            return "events/qrCode"
        case .postCheckIn:
            return "events/checkIn"
        case .getAttendedStudents:
            return "events/attendedStudents"
        case .checkInStudent:
            return "events/checkInStudent"
        case .deleteLecture(id: let id):
            return "lectures/\(id)"
        case .editLecture:
            return "lectures"
        case .editEvent:
            return "events"
        case .deleteEvent(eventId: let id):
            return "events/\(id)"
        case .postCheckOut:
            return "events/checkOut"
        case .getLecture(id: let id):
            return "lectures/\(id)"
        case .importStudents:
            return "users/importStudents"
        case .getAllGroups:
            return "groups"
        case .editGroup:
            return "groups"
        case .deleteGroup(let id):
            return "groups/\(id)"
        case .sharedCheckIn:
            return "events/sharedCheckIn"
        case .sharedCheckOut:
            return "events/sharedCheckOut"
        case .checkOutStudent:
            return "events/checkOutStudent"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getUser:
            return .get
        case .createUser:
            return .post
        case .getAttendableLectures:
            return .get
        case .getAllUsers:
            return .get
        case .postLecture:
            return .post
        case .getAllFaculties:
            return .get
        case .postCreateGroup:
            return .post
        case .getLedLectures:
            return .get
        case .postEvent:
            return .post
        case .getStudentEventsByDate:
            return .get
        case .getLectorEventsByDate:
            return .get
        case .getQrCode:
            return .get
        case .postCheckIn:
            return .post
        case .getAttendedStudents:
            return .get
        case .checkInStudent:
            return .post
        case .deleteLecture:
            return .delete
        case .editLecture:
            return .put
        case .editEvent:
            return .put
        case .deleteEvent:
            return .delete
        case .postCheckOut:
            return .post
        case .getLecture:
            return .get
        case .importStudents:
            return .post
        case .getAllGroups:
            return .get
        case .editGroup:
            return .put
        case .deleteGroup:
            return .delete
        case .sharedCheckIn:
            return .post
        case .sharedCheckOut:
            return .post
        case .checkOutStudent:
            return .post
        }
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var task: Task {
        switch self {
        case .getUser:
            return .requestPlain
        case .createUser(let name, let surname):
            return .requestJSONEncodable(CreateUserRequest(name: name, surname: surname))
        case .getAttendableLectures:
            return .requestPlain
        case .getAllUsers:
            return .requestPlain
        case .postLecture(let lecture):
            return .requestJSONEncodable(lecture)
        case .getAllFaculties:
            return .requestPlain
        case .postCreateGroup(let group):
            return .requestJSONEncodable(group)
        case .getLedLectures:
            return .requestPlain
        case .postEvent(let event):
            return .requestJSONEncodable(event)
        case .getStudentEventsByDate(let dateFrom, let dateTo, let userId):
            return .requestParameters(parameters: ["dateFrom": dateFrom, "dateTo": dateTo, "userId": userId], encoding: URLEncoding.default)
        case .getLectorEventsByDate(let dateFrom, let dateTo, let userId):
            return .requestParameters(parameters: ["dateFrom": dateFrom, "dateTo": dateTo, "userId": userId], encoding: URLEncoding.default)
        case .getQrCode(let eventId):
            return .requestParameters(parameters: ["eventId": eventId], encoding: URLEncoding.default)
        case .postCheckIn(let request):
            return .requestParameters(parameters: ["eventId": request.eventId,
                                                   "qrId": request.qrId,
                                                   "userId": request.userId],
                                      encoding: URLEncoding.default)
        case .getAttendedStudents(let eventId):
            return .requestParameters(parameters: ["eventId": eventId], encoding: URLEncoding.default)
        case .checkInStudent(let studentCheckInRequest):
            return .requestParameters(parameters: ["eventId": studentCheckInRequest.eventId,
                                                   "userId": studentCheckInRequest.userId],
                                      encoding: URLEncoding.default)
        case .deleteLecture:
            return .requestPlain
        case .editLecture(let lecture):
            return .requestJSONEncodable(lecture)
        case .editEvent(let event):
            return .requestJSONEncodable(event)
        case .deleteEvent:
            return .requestPlain
        case .postCheckOut(let checkOutRequest):
            return .requestParameters(parameters: ["eventId": checkOutRequest.eventId,
                                                   "qrId": checkOutRequest.qrId,
                                                   "userId": checkOutRequest.userId],
                                      encoding: URLEncoding.default)
        case .getLecture:
            return .requestPlain
        case .importStudents(let fileURL):
            let formData: [Moya.MultipartFormData] = [MultipartFormData(provider: .file(fileURL), name: "file")]
            return .uploadMultipart(formData)
        case .getAllGroups:
            return .requestPlain
        case .editGroup(let group):
            return .requestJSONEncodable(group)
        case .deleteGroup:
            return .requestPlain
        case .sharedCheckIn(let req):
            return .requestParameters(parameters:
                                        ["eventId": req.eventId,
                                         "userId": req.userId,
                                         "senderId": req.senderId],
                                      encoding: URLEncoding.default)
        case .sharedCheckOut(let req):
            return .requestParameters(parameters:
                                        ["eventId": req.eventId,
                                         "userId": req.userId,
                                         "senderId": req.senderId],
                                      encoding: URLEncoding.default)
        case .checkOutStudent(let req):
            return .requestParameters(parameters: ["eventId": req.eventId,
                                                   "userId": req.userId],
                                      encoding: URLEncoding.default)
        }
    }
    
    var headers: [String: String]? {
        nil
    }
}

extension AttendanceAPI: AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? {
        .bearer
    }
}
