//
//  FAQTableViewCell.swift
//  RCRC
//
//  Created by anand madhav on 11/08/20.
//

import UIKit

class FAQTableViewCell: UITableViewCell {

    @IBOutlet weak var questionLabel: LocalizedLabel!
    @IBOutlet weak var accessoryButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        self.selectionStyle = .none
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
    
    func configure(title: String?, selectedIndexPath: IndexPath?, currentIndexPath: IndexPath) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let messageAttrString = NSMutableAttributedString(string: title ?? "",
                                                          attributes: [
                                                            NSAttributedString.Key.font: Fonts.CodecRegular.fourteen, NSAttributedString.Key.foregroundColor: Colors.black, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        questionLabel.attributedText = messageAttrString
        
        if selectedIndexPath == currentIndexPath {
            accessoryButton.setImage(UIImage(named: "dropdowm-gray"), for: .normal)
        } else {
            accessoryButton.setImage(UIImage(named: "dropup-gray")?.setNewImageAsPerLanguage(), for: .normal)
        }
    }
}
