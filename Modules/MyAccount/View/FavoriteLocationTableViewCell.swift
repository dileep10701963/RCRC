//
//  FavoriteLocationTableViewCell.swift
//  RCRC
//
//  Created by Errol on 19/02/21.
//

import UIKit

class FavoriteLocationTableViewCell: UITableViewCell {

    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var locationType: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
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
