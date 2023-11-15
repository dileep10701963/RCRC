//
//  MyAccountNewTableCell.swift
//  RCRC
//
//  Created by Aashish Singh on 18/01/23.
//

import UIKit

class MyAccountNewTableCell: UITableViewCell {

    @IBOutlet weak var optionLabel: UILabel!
    @IBOutlet weak var optionArrowImage: UIImageView!
    @IBOutlet weak var cellBackGroundArrow: UIImageView!
    @IBOutlet weak var optionBackgroundImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        cellBackGroundArrow.image = cellBackGroundArrow.image?.setNewImageAsPerLanguage()
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

    func configureCell(indexPath: IndexPath, data: [MyAccountModel], selectedIndex: Int) {
        self.optionBackgroundImage.image = data[indexPath.row].image?.setNewImageAsPerLanguage()
        self.optionLabel.text = data[indexPath.row].option
        optionArrowImage.image = Images.rightArrowGreen?.setNewImageAsPerLanguage()
    }
    
}

extension UIImageView {
    func setAndChangeImageColor(image: UIImage, color: UIColor) {
        let templateImage = image.withRenderingMode(.alwaysTemplate)
        self.image = templateImage
        self.tintColor = color
    }
}
