//
//  SearchPreferenceTableViewCell.swift
//  RCRC
//
//  Created by Errol on 06/10/20.
//

import UIKit

class SearchPreferenceTableViewCell: UITableViewCell {

    @IBOutlet weak var checkedImage: UIImageView!
    @IBOutlet weak var preferenceLabel: LocalizedLabel!
    @IBOutlet weak var separatorLabel: LocalizedLabel!
    var isChecked: Bool = false

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func layoutSubviews() {
        if isChecked {
            checkedImage.image = Images.checked
            checkedImage.setAndChangeImageColor(image: Images.checked!, color: Colors.newGreen)
        } else {
            checkedImage.image = Images.unchecked
            checkedImage.setAndChangeImageColor(image: Images.unchecked!, color: Colors.newGreen)
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
}
