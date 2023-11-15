//
//  CorrespondenceTableViewCell.swift
//  RCRC
//
//  Created by anand madhav on 17/11/20.
//

import UIKit

class CorrespondenceTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: LocalizedLabel!
    @IBOutlet weak var correspondenceMenuImageView: UIImageView!

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
