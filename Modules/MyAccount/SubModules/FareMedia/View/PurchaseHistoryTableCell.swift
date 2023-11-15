//
//  PurchaseHistoryTableCell.swift
//  RCRC
//
//  Created by Bhavin Nagaria on 04/05/23.
//

import UIKit

class PurchaseHistoryTableCell: UITableViewCell {
    @IBOutlet weak var purchaseHeaderLabel: LocalizedLabel!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var imageBottomConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        purchaseHeaderLabel.setAlignment()
        purchaseHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        self.selectionStyle = .none
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
    
    func configure(title: String?, selectedIndexPath: IndexPath?, currentIndexPath: IndexPath) {
        purchaseHeaderLabel.text = title?.localized
        
        if selectedIndexPath == currentIndexPath {
            accessoryButton.setImage(Images.upArrow, for: .normal)//dropDownArrow
            imageBottomConstraint.constant = 0
        } else {
            accessoryButton.setImage(Images.downArrow, for: .normal)//rightArrowGreen?.setNewImageAsPerLanguage()
            imageBottomConstraint.constant = 16
        }
    }
    
}
