//
//  SearchTextField.swift
//  RCRC
//
//  Created by Errol on 06/08/20.
//

import Foundation
import UIKit

extension UISearchBar {
    var textField: UITextField? {
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            for view in (self.subviews[0]).subviews {
                if let textField = view as? UITextField {
                    return textField
                }
            }
        }
        return nil
    }
}
