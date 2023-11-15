//
//  TravelHistoryHeader.swift
//  RCRC
//
//  Created by Saheba Juneja on 03/05/23.
//

import UIKit

class TravelHistoryHeader: UITableViewHeaderFooterView {
    @IBOutlet weak var transparentHeaderButton: UIButton!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var headerLabel: LocalizedLabel!
    var sectionTapped: ((Int) -> Void)?
    //let dropUpArrow = UIImage(named: "DropUpArrow")

    func configureHeaderTitle(title: String?, section: Int, selected: Int?) {
        self.headerLabel.setAlignment()
        self.headerLabel.text = title?.localized
        self.transparentHeaderButton.tag = section
        self.headerLabel.setAlignment()
        if section == selected {
            accessoryButton.setImage(Images.upArrow, for: .normal)
        } else {
            accessoryButton.setImage(Images.downArrow, for: .normal)
        }
    }

    @IBAction func transparentButtonHeaderTapped(_ sender: UIButton) {
        self.sectionTapped?(sender.tag)
    }
}
