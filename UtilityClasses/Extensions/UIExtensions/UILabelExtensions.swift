//
//  UILabelExtensions.swift
//  RCRC
//
//  Created by Errol on 04/02/21.
//

import UIKit

extension UILabel {
    /// Set LTR or RTL text alignment
    func setAlignment() {
        if currentLanguage == .arabic || currentLanguage == .urdu {
            self.textAlignment = .right
        } else {
            self.textAlignment = .left
        }
    }
}
