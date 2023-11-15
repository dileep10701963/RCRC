//
//  LocalizedTextFiled.swift
//  RCRC
//
//  Created by Ganesh Shinde on 26/11/20.
//

import Foundation
import UIKit

class LocalizedTextField: UITextField {
    override func awakeFromNib() {
        if let text = text {
            self.text = text.localized
        }

        if let placeholder = placeholder {
            self.placeholder = placeholder.localized
        }
    }
}
