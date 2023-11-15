//
//  BusTableViewCell.swift
//  RCRC
//
//  Created by Aashish Singh on 21/10/22.
//

import UIKit

class BusTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var answerLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var answerLabelBottomConstraint: NSLayoutConstraint!
    
    var cellTapped: ((BusTableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        accessoryButton.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.font = Fonts.CodecRegular.sixteen
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(title: String, selectedIndexPath: IndexPath?, currentIndexPath: IndexPath, description: NSMutableAttributedString?) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let messageAttrString = NSMutableAttributedString(string: title,
                                                          attributes: [NSAttributedString.Key.font: Fonts.CodecRegular.seventeen, NSAttributedString.Key.foregroundColor: Colors.textColor, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        titleLabel.attributedText = messageAttrString
        if selectedIndexPath == currentIndexPath {
            answerLabelTopConstraint.constant = 16
            answerLabelBottomConstraint.constant = 16
            answerLabel.attributedText = description?.trimmedAttributedString()
            accessoryButton.setImage(Images.busCollapse, for: .normal)

        } else {
            answerLabelTopConstraint.constant = 0
            answerLabelBottomConstraint.constant = 4
            
            answerLabel.attributedText = NSAttributedString(string: "")
            accessoryButton.setImage(Images.busExpand, for: .normal)
        }
        //answerLabel.sizeToFit()
        //answerLabel.lineBreakMode = .byWordWrapping
    }
    
    @IBAction func accessoryButtonTapped(_ sender: UIButton) {
        self.cellTapped?(self)
    }
}
