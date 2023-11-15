//
//  ExistingCardTableViewCell.swift
//  RCRC
//
//  Created by Saheba Juneja on 11/10/22.
//

import UIKit

class ExistingCardTableViewCell: UITableViewCell {
    @IBOutlet weak var cardNumberLabel: UILabel!    
    var existingCardItem: ExistingCardItem? {
        didSet {
            guard let cardItemModel = existingCardItem else {
                return
            }
            self.cardNumberLabel.text = "Credit Card \(cardItemModel.bankCard?.maskedCardNumber ?? "")"
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
    
}
