//
//  SideMenuCell.swift
//  RCRC
//
//  Created by Admin on 04/03/21.
//

import UIKit

class SideMenuCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sideMenuImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
//        sideMenuImageView.contentMode = .scaleAspectFit
        nameLabel.setAlignment()
        nameLabel.textColor = Colors.buttonTintColor
        nameLabel.font = Fonts.CodecRegular.twenty
        selectionStyle = .none
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
}
