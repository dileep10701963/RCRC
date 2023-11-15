//
//  ReportTextField.swift
//  RCRC
//
//  Created by Errol on 27/04/21.
//

import UIKit

protocol ReportTextFieldDelegate: AnyObject {
    func reportTextField(_ textField: UITextField)
    func reportTextFieldLocationButtonTapped()
}

extension ReportTextFieldDelegate {
    func reportTextField(_ textField: UITextField) {}
    func reportTextFieldLocationButtonTapped() {}
}

class ReportTextField: UITextField {

    private let textFieldPadding = currentLanguage == .english ? UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 30) : UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 10)
    weak var reportDelegate: ReportTextFieldDelegate?

    override init(frame: CGRect) {
        super.init(frame: frame)
        delegate = self
        initialize()
    }

    private func initialize() {
        self.rightViewMode = .always
        clipsToBounds = true
        layer.cornerRadius = 10
        layer.borderWidth = 1
        layer.borderColor = Colors.textFieldBorder.cgColor
        textColor = .black
        font = Fonts.CodecRegular.sixteen//Fonts.RptaSignage.eighteen
        setAlignment()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        delegate = self
        initialize()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    func configure(text: String? = nil, placeholder: String? = nil, rightImage: UIImage? = nil) {
        self.text = text
        self.placeholder = text

        let button = UIButton()
        button.setImage(rightImage, for: .normal)
        button.imageEdgeInsets = currentLanguage == .english ? UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -15)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 25)
        button.contentMode = .center
        if let rightImage = rightImage, rightImage == Images.currentLocationMarker {
            button.addTarget(self, action: #selector(locationButtonTapped(_:)), for: .touchUpInside)
        } else {
            button.tintColor = Colors.darkGray
            button.isUserInteractionEnabled = false
        }
        self.rightView = button
        layoutIfNeeded()
    }
    
    func configureTextField(text: String? = nil, placeholder: String? = nil, rightImage: UIImage? = nil) {
        layer.borderColor = UIColor(hexString: "#0000", alpha: 0.0).cgColor //Colors.white.cgColor
        self.text = text
        self.placeholder = placeholder
        self.backgroundColor = .clear

        let button = UIButton()
        button.setImage(rightImage, for: .normal)
        button.imageEdgeInsets = currentLanguage == .english ? UIEdgeInsets(top: 0, left: -15, bottom: 0, right: 0) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: -15)
        button.frame = CGRect(x: 0, y: 0, width: 00, height: 20)
        button.contentMode = .center
        if let rightImage = rightImage, rightImage == Images.currentLocationMarker {
            button.addTarget(self, action: #selector(locationButtonTapped(_:)), for: .touchUpInside)
        } else {
            button.titleLabel?.font = Fonts.CodecRegular.fourteen
            button.tintColor = Colors.black
            button.isUserInteractionEnabled = false
        }
        self.rightView = button
        layoutIfNeeded()
    }

    @objc private func locationButtonTapped(_ sender: UIButton) {
        reportDelegate?.reportTextFieldLocationButtonTapped()
    }

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textFieldPadding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textFieldPadding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textFieldPadding)
    }
}

extension ReportTextField: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        reportDelegate?.reportTextField(textField)
        if tag == 1 {
            return true
        } else {
            return false
        }
    }
}
