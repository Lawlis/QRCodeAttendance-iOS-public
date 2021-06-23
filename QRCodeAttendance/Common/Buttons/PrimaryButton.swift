//
//  RoundButton.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-04.
//

import UIKit

@IBDesignable
final class PrimaryButton: UIButton {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .primaryAccent()
        setTitleColor(.white, for: .normal)
        borderWidth = 2
        borderColor = UIColor(red: 231, green: 247, blue: 249, alpha: 1)
        cornerRadius = self.frame.height / 2
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
