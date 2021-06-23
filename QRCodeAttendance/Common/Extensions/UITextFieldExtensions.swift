//
//  UITextViewExtensions.swift
//  QRCodeAttendance-Prod
//
//  Created by Laurynas Letkauskas on 2021-04-01.
//

import UIKit

extension UITextField {
    
    func setInputViewDatePicker(target: Any, selector: Selector) {
        let screenWidth = UIScreen.main.bounds.width
        let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 216))
        datePicker.datePickerMode = .date
        
        datePicker.minimumDate = Date()
        datePicker.sizeToFit()
        datePicker.addTarget(target, action: selector, for: .valueChanged)
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        self.inputView = datePicker
        
        let toolBar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: screenWidth, height: 44.0))
        let barButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(tapCancel))
        toolBar.setItems([barButton], animated: false)
        self.inputAccessoryView = toolBar
    }
    
    @objc
    func tapCancel() {
        self.resignFirstResponder()
    }
    
}
