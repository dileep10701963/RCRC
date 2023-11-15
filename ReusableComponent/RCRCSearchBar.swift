//
//  RCRCSearchBar.swift
//  RCRC
//
//  Created by Errol on 19/07/21.
//

import UIKit

final class RCRCSearchBar: UISearchBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }

    private func initialize() {
        textField?.font = Fonts.RptaSignage.eighteen
        textField?.layer.borderWidth = Constants.textFieldBorderWidth
        textField?.layer.borderColor = UIColor.clear.cgColor
        textField?.cornerRadius = Constants.textFieldCornerRadius
        tintColor = Colors.green
        textField?.setAlignment()
    }
}
