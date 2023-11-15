//
//  LocalizedLabel.swift
//  RCRC
//
//  Created by Ganesh Shinde on 26/11/20.
//

import UIKit

class LocalizedLabel: UILabel {

    override func awakeFromNib() {
        self.text = text?.localized
        self.setAlignment()
    }

    // Added this for UITableView
    override func layoutSubviews() {
        self.text = text?.localized
        self.setAlignment()
    }
}
