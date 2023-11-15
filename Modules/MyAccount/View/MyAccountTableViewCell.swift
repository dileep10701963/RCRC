//
//  MyAccountTableViewCell.swift
//  RCRC
//
//  Created by Errol on 17/11/20.
//

import UIKit

class MyAccountTableViewCell: UITableViewCell {

    @IBOutlet weak var optionImage: UIImageView!
    @IBOutlet weak var optionLabel: LocalizedLabel!

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

    func configureCell(indexPath: IndexPath, data: [MyAccountModel]) {
        self.optionImage.image = data[indexPath.row].image
        self.optionLabel.text = data[indexPath.row].option
    }
}
