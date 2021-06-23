//
//  SecondaryButton.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-16.
//

import UIKit

@IBDesignable
final class SecondaryButton: UIButton {
    
    private var shadowLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .white
        setTitleColor(.secondaryLabel, for: .normal)
        borderWidth = 2
        borderColor = .primaryAccent()
        cornerRadius = self.frame.height / 2
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        if shadowLayer == nil {
            shadowLayer = CAShapeLayer()
            shadowLayer.path = UIBezierPath(roundedRect: bounds, cornerRadius: 12).cgPath
            shadowLayer.fillColor = UIColor.white.cgColor

            shadowLayer.shadowColor = UIColor.primaryAccent().cgColor
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOffset = CGSize(width: 1, height: 1)
            shadowLayer.shadowOpacity = 0.8
            shadowLayer.shadowRadius = 2

            layer.insertSublayer(shadowLayer, at: 0)
        }
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.backgroundColor = .primaryAccent()
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    var cornerRadius: CGFloat = 0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    var borderWidth: CGFloat = 0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
