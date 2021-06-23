//
//  TextInputView.swift
//  QRCodeAttendance
//
//  Created by Laurynas Letkauskas on 2021-03-04.
//

import Foundation
import UIKit

extension TextInputView {
    
    enum State {
        case normal
        case error
    }
    
    enum Style {
        case field
        case fieldWithPrefix(prefix: String)
        case fieldWithPrefixAndAction(prefix: String, actionButtonIcon: UIImage?)
        case fieldWithAction(actionButtonIcon: UIImage?)
    }
}

class TextInputView: UIView {
    
    // MARK: - UI Components

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var leftImageView: UIImageView!

    // MARK: - States
    
    private(set) var state: State = .normal
    
    private(set) var maximumCharactersCount: Int?
    
    var onAction: (() -> Void)?
    var onTextFieldEntered: ((_ charCount: Int) -> Void)?
    var onTextFieldReturn: (() -> Void)?
    var onStateChange: ((_ state: State) -> Void)?
    var onTextChange: ((_ text: String?) -> Void)?

    // MARK: - Init    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        loadContentFromNib()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        loadContentFromNib()
        setup()
    }
    
    private func setup() {
        containerView.layer.borderColor = UIColor.lightGrayBorder().cgColor
        containerView.layer.borderWidth = 2
        containerView.layer.cornerRadius = 8
        containerView.layer.masksToBounds = true
        textField.delegate = self
        textField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    @discardableResult
    func setMinimumCharactersCount(_ count: Int) -> Self {
        maximumCharactersCount = count
        return self
    }
    
    @discardableResult
    func setSecureInput(_ secureInput: Bool) -> Self {
        textField.isSecureTextEntry = secureInput
        return self
    }
    
    var isEmpty: Bool {
        guard let text = textField.text else {
            return true
        }
        return text.isEmpty
    }
    
    var text: String {
        return textField.text ?? ""
    }
    
    @discardableResult
    func setPlaceholder(_ text: String) -> Self {
        textField.placeholder = text
        return self
    }
    
    func setText(_ text: String?) {
        textField.text = text
    }
    
    @discardableResult
    func setKeyboardType(_ keyboardType: UIKeyboardType) -> Self {
        textField.keyboardType = keyboardType
        return self
    }
    
    @discardableResult
    func setReturnKeyType(_ returnKeyType: UIReturnKeyType) -> Self {
        textField.returnKeyType = returnKeyType
        return self
    }
    
    @discardableResult
    func setFontSize(_ size: CGFloat) -> Self {
        return self
    }
    /// Set to .username, .password, .newpassword or .oneTimeCode in order to use iOS autofill funcionality. Default nil
    @discardableResult
    func setTextContentType(_ contenType: UITextContentType) -> Self {
        textField.textContentType = contenType
        return self
    }
    
    @discardableResult
    func setImage(_ image: UIImage?) -> Self {
        leftImageView.image = image
        return self
    }
    
    @discardableResult
    func setImageTintColor(_ color: UIColor) -> Self {
        leftImageView.tintColor = color
        return self
    }
    
    // MARK: - Styling
    
//    @discardableResult
//    func apply(style: Style) -> Self {
//        switch style {
//        case .field:
//            prefixContainer.isHidden = true
//            actionButton.isHidden = true
//        case .fieldWithPrefix(let prefix):
//            actionButton.isHidden = true
//            prefixContainer.isHidden = false
//            prefixLabel.text = prefix
//        case .fieldWithPrefixAndAction(let prefix, let actionButtonIcon):
//            prefixContainer.isHidden = false
//            actionButton.isHidden = false
//            prefixLabel.text = prefix
//            actionButton.setImage(actionButtonIcon, for: .normal)
//        case .fieldWithAction(let actionButtonIcon):
//            prefixContainer.isHidden = true
//            actionButton.isHidden = false
//            actionButton.setImage(actionButtonIcon, for: .normal)
//        }
//        return self
//    }
    
    // MARK: - State changing
    
    func setState(_ state: State) {
        guard self.state != state else {
            return
        }
        self.state = state
        onStateChange?(state)
        switch state {
        case .normal:
            containerView.layer.borderColor = UIColor.lightGrayBorder().cgColor
            textField.textColor = .black
        case .error:
            containerView.layer.borderColor = UIColor.red.cgColor
            textField.textColor = .black
        }
    }
    
    // MARK: - Actions
    
    @IBAction private func onActionButtonTap(_ sender: Any) {
        onAction?()
    }

    @IBAction private func editingChanged(_ textField: UITextField) {
        onTextChange?(textField.text)
    }

    @objc
    func textFieldDidChange(textField: UITextField) {
        guard let text = textField.text else {
            onTextFieldEntered?(0)
            return
        }
        onTextFieldEntered?(text.count)
    }
}

extension TextInputView: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        onTextFieldReturn?()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text,
            let maximumCharactersCount = maximumCharactersCount else {
            return true
        }
        let count = text.count + string.count - range.length
        return count <= maximumCharactersCount
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        setState(.normal)
    }
}
