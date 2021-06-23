//
//  ScannerViewController.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-04-11.
//

import UIKit
import AVFoundation
import Moya

struct EventCheckInRequest: Codable {
    var eventId: Int
    var qrId: String
    var userId: String
}

struct EventCheckOutRequest: Codable {
    var eventId: Int
    var qrId: String
    var userId: String
}

struct CheckInStudentRequest: Codable {
    var eventId: Int
    var userId: String
}

struct CheckOutStudentRequest: Codable {
    var eventId: Int
    var userId: String
}

struct EventSharedCheckIn: Codable {
    var eventId: Int
    var userId: String
    var senderId: String
}

struct EventSharedCheckOut: Codable {
    var eventId: Int
    var userId: String
    var senderId: String
}

enum ScanType {
    case eventQRCodeCheckIn
    case eventQRCodeCheckOut
    case scanAColleagueCheckIn
    case scanAColleagueCheckOut
    case studentQRCodeCheckIn
    case studentQRCodeCheckOut
}

extension SegueIdentifier {
    static let unwindFromScanner = SegueIdentifier(rawValue: "UnwindFromScanner")
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, Networkable {
    
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    var eventId: Int!
    var userId: String!
    var scanType: ScanType!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        captureSession = AVCaptureSession()
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        captureSession.startRunning()
    }
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported",
                                   message: "Your device does not support scanning a code from an item. Please use a device with a camera.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
    
    // swiftlint:disable:next function_body_length
    func found(code: String) {
        switch scanType {
        case .eventQRCodeCheckIn:
            let request = EventCheckInRequest(
                eventId: eventId,
                qrId: code,
                userId: userId
            )
            postCheckIn(checkInRequest: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let resp):
                    self.handleResponse(resp: resp)
                case .failure(let error):
                    if error.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                        self.performSegue(identifier: .unwindFromScannerToEvents, sender: nil)
                    } else {
                        self.alert(message: error.localizedDescription)
                    }
                }
            }
        case .eventQRCodeCheckOut:
            let request = EventCheckOutRequest(
                eventId: eventId,
                qrId: code,
                userId: userId
            )
            
            postCheckOut(checkOutRequest: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let resp):
                    self.handleResponse(resp: resp)
                case .failure(let error):
                    if error.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                        self.performSegue(identifier: .unwindFromScannerToEvents, sender: nil)
                    } else {
                        self.alert(message: error.localizedDescription)
                    }
                }
            }
        case .studentQRCodeCheckIn:
            let request = CheckInStudentRequest(
                eventId: eventId,
                userId: code
            )
            
            postCheckInStudent(studentCheckInRequest: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let resp):
                    self.handleResponse(resp: resp)
                case .failure(let error):
                    if error.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                        self.performSegue(identifier: .unwindFromScannerToEvents, sender: nil)
                    } else {
                        self.alert(message: error.localizedDescription)
                    }
                }
            }
        case .studentQRCodeCheckOut:
            let request = CheckOutStudentRequest(
                eventId: eventId,
                userId: code
            )
            
            postCheckOutStudent(studentCheckOutRequest: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let resp):
                    self.handleResponse(resp: resp)
                case .failure(let error):
                    if error.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                        self.performSegue(identifier: .unwindFromScannerToEvents, sender: nil)
                    } else {
                        self.alert(message: error.localizedDescription)
                    }                }
            }
        case .scanAColleagueCheckIn:
            let request = EventSharedCheckIn(eventId: eventId, userId: code, senderId: userId)
            postSharedCheckIn(checkInRequest: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let resp):
                    self.handleResponse(resp: resp)
                case .failure(let error):
                    if error.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                        self.performSegue(identifier: .unwindFromScannerToEvents, sender: nil)
                    } else {
                        self.alert(message: error.localizedDescription)
                    }                }
            }
        case .scanAColleagueCheckOut:
            let request = EventSharedCheckOut(eventId: eventId, userId: code, senderId: userId)
            postSharedCheckOut(checkOutRequest: request) { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let resp):
                    self.handleResponse(resp: resp)
                case .failure(let error):
                    if error.localizedDescription == "The data couldn’t be read because it isn’t in the correct format." {
                        self.performSegue(identifier: .unwindFromScannerToEvents, sender: nil)
                    } else {
                        self.alert(message: error.localizedDescription)
                    }
                }
            }
        case .none:
            print("none")
        }

    }
    
    private func handleResponse(resp: CheckResponse) {
        if resp.status == "BAD_REQUEST" {
            self.alert(message: resp.message)
        } else {
            self.performSegue(identifier: .unwindFromScannerToEvents, sender: nil)
        }
    }
    
    func postCheckIn(checkInRequest: EventCheckInRequest, completion: @escaping (Result<CheckResponse, Error>) -> Void) {
        request(target: .postCheckIn(checkInRequest: checkInRequest), completion: completion)
    }
    
    func postCheckOut(checkOutRequest: EventCheckOutRequest, completion: @escaping (Result<CheckResponse, Error>) -> Void) {
        request(target: .postCheckOut(checkOutRequest: checkOutRequest), completion: completion)
    }
    
    func postSharedCheckIn(checkInRequest: EventSharedCheckIn, completion: @escaping (Result<CheckResponse, Error>) -> Void) {
        request(target: .sharedCheckIn(req: checkInRequest), completion: completion)
    }
    
    func postSharedCheckOut(checkOutRequest: EventSharedCheckOut, completion: @escaping (Result<CheckResponse, Error>) -> Void) {
        request(target: .sharedCheckOut(req: checkOutRequest), completion: completion)
    }
    
    func postCheckInStudent(studentCheckInRequest: CheckInStudentRequest, completion: @escaping (Result<CheckResponse, Error>) -> Void) {
        request(target: .checkInStudent(studentCheckInRequest: studentCheckInRequest), completion: completion)
    }
    
    func postCheckOutStudent(studentCheckOutRequest: CheckOutStudentRequest, completion: @escaping (Result<CheckResponse, Error>) -> Void) {
        request(target: .checkOutStudent(studentCheckOutRequest: studentCheckOutRequest), completion: completion)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
//        return .portrait
//    }
}

struct EmptyResponse: Decodable {}

struct CheckResponse: Decodable {
    let status: String
    let message: String
    let timestamp: String
    
    init(emptyResponse: EmptyResponse) {
        self.status = "Ok"
        self.message = "Successfully checked in!"
        self.timestamp = ""
    }
}
