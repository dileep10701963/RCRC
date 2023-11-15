//
//  FavoriteSelectionTableViewCell.swift
//  RCRC
//
//  Created by Errol on 20/04/21.
//

import UIKit

class FavoriteSelectionTableViewCell: UITableViewCell {

    @IBOutlet weak var selectionImage: UIImageView!
    @IBOutlet weak var selectionLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionLabel.setAlignment()
        selectionLabel.font = Fonts.RptaSignage.eighteen
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
}
