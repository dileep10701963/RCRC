//
//  LocalizedButton.swift
//  RCRC
//
//  Created by Ganesh Shinde on 26/11/20.
//

import Foundation
import UIKit

class LocalizedButton: UIButton {

    override func awakeFromNib() {
        for state in [UIControl.State.normal, UIControl.State.highlighted, UIControl.State.selected, UIControl.State.disabled] {
            self.setTitle(currentTitle, for: state)
            self.setAlignment()
        }
    }

    override func layoutSubviews() {
        for state in [UIControl.State.normal, UIControl.State.highlighted, UIControl.State.selected, UIControl.State.disabled] {
            self.setTitle(currentTitle, for: state)
            self.setAlignment()
        }
    }
}
