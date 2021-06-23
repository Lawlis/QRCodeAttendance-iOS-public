//
//  StringExtensions.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-04.
//

import Foundation
import UIKit

extension String {
    
    // MARK: - Public Methods
    
    // MARK: - Class name
    
    /// Gives class name of object as `String`
    ///
    /// - Parameter object: any class
    /// - Returns: class name or empty `String`
    static func classNameAsString<T>(_ object: T) -> String {
        let name = String(describing: object).components(separatedBy: ".").first ?? ""
        return name
    }
    
    /// Gives class instance name of object as `String`
    ///
    /// - Parameter object: any class
    /// - Returns: class instance name or empty `String`
    static func classInstanceNameAsString<T>(_ object: T) -> String {
        let name = String(describing: type(of: object)).components(separatedBy: ".").first ?? ""
        return name
    }
    
    // MARK: - First letter uppercased
    
    /// Makes first character uppercased of `String`
    var firstUppercased: String {
        guard let first = first else {
            return ""
        }
        
        let fullText = String(first).uppercased() + dropFirst()
        return fullText
    }
    
    // MARK: - Remove white spaces and new lines from `String`
    
    /// Removes white spaces and new lines from `String`
    ///
    /// - Returns: text without whites spaces and new lines
    func removeWhiteSpacesAndNewLines() -> String {
        return self.components(separatedBy: .whitespacesAndNewlines).joined()
    }
    
    // MARK: - Remove prefix
    
    /// Removes given prefix from string.
    ///
    /// - Parameter prefix: will be removed from `String`.
    mutating func removePrefix(_ prefix: String) {
        guard hasPrefix(prefix) else {
            return
        }
        self = String(dropFirst(prefix.count))
    }
    
    // MARK: - Group up text
    
    /// Groups up text by entered `Int` value
    ///
    /// - Parameters:
    ///   - groupedUpTo: value means how text will be grouped
    /// - Returns: grouped text
    func groupUpTo(_ groupedUpTo: Int) -> String {
        var formatted = ""
        var groupOfNumbers = ""
        
        for character in self {
            if groupOfNumbers.count == groupedUpTo {
                formatted += groupOfNumbers + " "
                groupOfNumbers = ""
            }
            groupOfNumbers.append(character)
        }
        // The remaining text
        formatted += groupOfNumbers
        
        return formatted
    }
    
    /// Adds character at given index and returns new string.
    ///
    /// - Parameters:
    ///   - character: The character that will be inserted to.
    ///   - index: The index where character will be inserted.
    /// - Returns: the new string with inserted character.
    func stringWithCharacter(_ character: Character, atIndex index: Int) -> String {
        var string = self
        string.insert(character, at: self.index(self.startIndex, offsetBy: index))
        return string
    }
    
    // MARK: - Compare app versions
    
    /// Compares versions
    ///
    /// - Parameters:
    ///   - newVersion: value to compare
    /// - Returns: `true` if new version is greater
    func isVersionSmaller(newVersion: String) -> Bool {
        let (currentVersionComponents, newVersionComponents) = createComponentListFromVersions(currentVersion: self,
                                                                                               newVersion: newVersion)
        for index in 0..<currentVersionComponents.count {
            let currentVersion = currentVersionComponents[index]
            let newVersion = newVersionComponents[index]
            
            if let currentVersionNumber = Int(currentVersion), let newVersionNumber = Int(newVersion) {
                // Compare numbers
                if currentVersionNumber > newVersionNumber {
                    return false
                } else if currentVersionNumber < newVersionNumber {
                    return true
                }
            }
        }
        // Versions are equal
        return false
    }
    
    /// Creates list of components separated by `.` from `String` (e.g. "2.1.0", "0.1.0")
    ///
    /// - Parameters:
    ///   - currentVersion: `String` will be converted to list
    ///   - newVersion: `String` will be converted to list
    /// - Returns: current and new version lists of components (e.g. "2.1.0" will be like ["2", "1", "0"])
    private func createComponentListFromVersions(currentVersion: String, newVersion: String) -> (current: [String], new: [String]) {
        let versionDelimiter = "."
        var currentVersionComponents = currentVersion.components(separatedBy: versionDelimiter)
        var newVersionComponents = newVersion.components(separatedBy: versionDelimiter)
        
        var countDifference = newVersionComponents.count - currentVersionComponents.count
        if countDifference < 0 {
            countDifference *= -1
        }
        
        if currentVersionComponents.count < newVersionComponents.count {
            currentVersionComponents = addMissingInitialVersionNumber(list: currentVersionComponents, times: countDifference)
        } else if currentVersionComponents.count > newVersionComponents.count {
            newVersionComponents = addMissingInitialVersionNumber(list: newVersionComponents, times: countDifference)
        }
        
        return (currentVersionComponents, newVersionComponents)
    }
    
    /// Adds initial version number x times to `[String]`
    ///
    /// - Parameters:
    ///   - list: to update
    ///   - times: will tell how many times need to add initial version number
    /// - Returns: update list of components
    private func addMissingInitialVersionNumber(list: [String], times: Int) -> [String] {
        let initialVersionNumber = "0"
        var newList = list
        
        for _ in 0..<times {
            newList.append(initialVersionNumber)
        }
        return newList
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin,
                                            attributes: [.font: font], context: nil)

        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin,
                                            attributes: [.font: font], context: nil)

        return ceil(boundingBox.width)
    }
}

extension Optional where Wrapped == String {

    var isEmpty: Bool {
        return self == nil || self?.isEmpty == true
    }

}
