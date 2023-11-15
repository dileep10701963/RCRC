//
//  EmptyTableViewCell.swift
//  RCRC
//
//  Created by Errol on 24/02/21.
//

import UIKit

class EmptyTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    static var identifier: String {
        return String(describing: self)
    }
}
