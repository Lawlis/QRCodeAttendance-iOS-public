//
//  QRCodeViewController.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-04-11.
//

import UIKit
import Moya

struct QrCodeResponse: Decodable {
    var qrId: String
}

class QRCodeViewController: UIViewController, Networkable {
    var provider: MoyaProvider<AttendanceAPI> = MoyaProviderFactory.makeAuthorizable(AttendanceAPI.self)
    
    @IBOutlet weak var QRImageView: UIImageView!
    
    var eventId: Int!
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(timerQrCode), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer.invalidate()
    }
    
    @objc
    private func timerQrCode() {
        getQrCode(eventId: eventId, completion: { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                self.handleQrCodeResponse(response.qrId)
            case .failure(let error):
                print(error)
            }
        })
    }
    
    private func handleQrCodeResponse(_ code: String) {
        QRImageView.image = generateQRCode(from: code)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }

        return nil
    }

    private func getQrCode(eventId: Int, completion: @escaping ((Result<QrCodeResponse, Error>) -> Void)) {
        request(target: .getQrCode(eventId: eventId), completion: completion)
    }
}
