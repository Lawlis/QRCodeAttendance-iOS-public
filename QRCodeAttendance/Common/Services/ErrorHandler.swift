//
//  ErrorHandler.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-11.
//

import Foundation
import Firebase
import UIKit.UIViewController
import Toast

/// Defines applicaiton errors.
enum AppError: Int, LocalizedError {
    
    /// Failed to get firebase user from Auth.auth()
    case noFirebaseUser = -1001
    
    case noIDToken
    
    case emailAlreadyInUse

    /// The application error domain.
    static let domain = "AppErrorDomain"
    
    /// - returns: A localized description of the error.
    var localizedDescription: String {
        switch self {
        case .noFirebaseUser:
            return "error_no_firebaseUser".localized
        case .noIDToken:
            return "error_no_firebaseIdToken".localized
        case .emailAlreadyInUse:
            return "email_already_in_use".localized
        }
    }
}

enum ValidationError: Int, LocalizedError {
    
    case emptyEmailField = -2001
    
    case emptyPasswordField
    
    case emptyEmailAndPassword
    
    case emptyNameField
    
    case emptySurnameField
    
    /// The application error domain.
    static let domain = "ValidationErrorDomain"
    
    /// - returns: A localized description of the error.
    var localizedDescription: String {
        switch self {
        case .emptyEmailField:
            return "login_error_empty_email".localized
        case .emptyPasswordField:
            return "login_error_empty_password".localized
        case .emptyEmailAndPassword:
            return "login_error_empty_email_password".localized
        case .emptyNameField:
            return "registration_error_empty_name".localized
        case .emptySurnameField:
            return "registration_error_empty_surname".localized
        }
    }
}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .emailAlreadyInUse:
            return "The email is already in use with another account"
        case .userNotFound:
            return "Account not found for the specified user. Please check and try again"
        case .userDisabled:
            return "Your account has been disabled. Please contact support."
        case .invalidEmail, .invalidSender, .invalidRecipientEmail:
            return "Please enter a valid email"
        case .networkError:
            return "Network error. Please try again."
        case .weakPassword:
            return "Your password is too weak. The password must be 6 characters long or more."
        case .wrongPassword:
            return "Your password is incorrect. Please try again or use 'Forgot password' to reset your password"
        default:
            return "Unknown error occurred"
        }
    }
}

extension UIViewController {
    func handleError(_ error: Error) {
        if let errorCode = AuthErrorCode(rawValue: error._code) {
            print(error.localizedDescription)
            view.makeToast(errorCode.errorMessage)
        } else if let error = ValidationError(rawValue: error._code) {
            print(error.localizedDescription)
            view.makeToast(error.localizedDescription)
        } else if let error = AppError(rawValue: error._code) {
            print(error.localizedDescription)
            view.makeToast(error.localizedDescription)
        }
    }

}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
