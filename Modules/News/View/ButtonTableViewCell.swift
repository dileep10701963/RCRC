//
//  ButtonTableViewCell.swift
//  RCRC
//
//  Created by Errol on 25/02/21.
//

import UIKit

class ButtonTableViewCell: UITableViewCell {

    @IBOutlet weak var button: UIButton!
    var buttonTapped: ((_ sender: UIButton) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.button.isUserInteractionEnabled = true
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

    @IBAction func buttonTapped(_ sender: UIButton) {
        buttonTapped?(sender)
    }
}
