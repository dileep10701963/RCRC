//
//  AlertAction.swift
//  RCRC
//
//  Created by Errol on 26/08/20.
//

import Foundation
import UIKit

//func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
//#if STAGING
//    Swift.print(items, separator: separator, terminator: terminator)
//#endif
//}

public enum AlertActionStyle: Int {
    case `default`
    case cancel
}

class AlertAction: LoadingButton {

    fileprivate var action: (() -> Void)?

    open var actionStyle: AlertActionStyle
    open var separator = UIImageView()

    init() {

        self.actionStyle = .cancel
        super.init(frame: CGRect.zero)
    }

    public convenience init(title: String, _ separatorEnabled: Bool = false, style: AlertActionStyle, action: (() -> Void)? = nil) {

        self.init()
        self.action = action
        self.addTarget(self, action: #selector(AlertAction.tapped(_:)), for: .touchUpInside)
        self.setTitle(title.localized, for: UIControl.State())
        if titleLabel?.text?.localized == Constants.logout.localized {
            if currentLanguage == .arabic {
                self.titleLabel?.font = Fonts.CodecBold.thirteen
            } else {
                self.titleLabel?.font = Fonts.CodecBold.fifteen
            }
        } else {
            self.titleLabel?.font = Fonts.CodecBold.fifteen
        }
         
        self.actionStyle = style
        style == .default ? (self.setTitleColor(Colors.white, for: UIControl.State())) : (self.setTitleColor(Colors.black, for: UIControl.State()))
        self.backgroundColor = UIColor(hexString: "6FCC00")
        self.cornerRadius = 12
//        self.setBackgroundImage(Images.popupButton, for: UIControl.State())
    }

    required public init?(coder aDecoder: NSCoder) {

        fatalError(Constants.initError)
    }

    @objc func tapped(_ sender: AlertAction) {

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.action?()
        }
    }

    @objc fileprivate func addSeparator() {

        separator.backgroundColor = Colors.borderColorGray
        self.addSubview(separator)
        separator.translatesAutoresizingMaskIntoConstraints = false
        separator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        separator.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        separator.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    }

    @objc fileprivate func addVerticalSeparator() {
        let verticalSeparator = UIView()
        verticalSeparator.translatesAutoresizingMaskIntoConstraints = false
        verticalSeparator.backgroundColor = Colors.borderColorGray
        self.addSubview(verticalSeparator)
        verticalSeparator.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 1).isActive = true
        verticalSeparator.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        verticalSeparator.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor).isActive = true
        verticalSeparator.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
    }
}
