//
//  UITableViewExtensions.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-12.
//

import UIKit

extension UITableView {
    
    // MARK: - Cells
    
    func registerCellNib<T>(withType type: T.Type) where T: UITableViewCell {
        let identifier: String = String.classNameAsString(type)
        let nib: UINib? = UINib(nibName: identifier, bundle: Bundle.main)
        register(nib, forCellReuseIdentifier: identifier)
    }
    
    func registerCellClass<T>(withType type: T.Type) where T: UITableViewCell {
        let identifier: String = String.classNameAsString(type)
        register(T.self, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCell<T>(indexPath: IndexPath? = nil) -> T where T: UITableViewCell {
        let identifier: String = String.classNameAsString(T.self)
        
        if let indexPath = indexPath {
            guard let cell = dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? T else {
                fatalError("Unable to cast cell as \(T.self) type")
            }
            return cell
        } else {
            guard let cell = dequeueReusableCell(withIdentifier: identifier) as? T else {
                fatalError("Unable to cast cell as \(T.self) type")
            }
            return cell
        }
    }
    
    // MARK: - Headers / Footers
    
    func registerHeaderFoorterNib<T>(withType type: T.Type) where T: UITableViewHeaderFooterView {
        let identifier: String = String.classNameAsString(type)
        let nib: UINib? = UINib(nibName: identifier, bundle: Bundle.main)
        register(nib, forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    func dequeueReusableHeaderFooter<T>() -> T where T: UITableViewHeaderFooterView {
        let identifier: String = String.classNameAsString(T.self)
        guard let headerFooterView = dequeueReusableHeaderFooterView(withIdentifier: identifier) as? T else {
            fatalError("Unable to cast HeaderFooterView as \(T.self) type")
        }
        return headerFooterView
       
    }

    func headerView<T>(of type: T.Type, completion: (T?) -> Void) {
        for section in 0..<numberOfSections {
            if let headerView = headerView(forSection: section) as? T {
                completion(headerView)
                return
            }
        }

        completion(nil)
    }
}

extension UITableView {

    func setBottomInset(to value: CGFloat) {
        let edgeInset = UIEdgeInsets(top: 0, left: 0, bottom: value, right: 0)

        self.contentInset = edgeInset
        self.scrollIndicatorInsets = edgeInset
    }
    
    func scrollToBottomRow(sectionIndex: Int = 0) {
        let indexPath = IndexPath(
            row: self.numberOfRows(inSection: sectionIndex) - 1,
            section: 0
        )
        self.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
}
