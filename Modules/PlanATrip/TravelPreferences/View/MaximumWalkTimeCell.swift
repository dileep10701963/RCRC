//
//  MaximumWalkTimeCell.swift
//  RCRC
//
//  Created by Aashish Singh on 15/07/22.
//

import UIKit

class MaximumWalkTimeCell: UITableViewCell {

    @IBOutlet weak var maximumWalkTimeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        maximumWalkTimeLabel.setAlignment()
        maximumWalkTimeLabel.attributedText = self.setAttributedStringToLabels(firstFont: Fonts.CodecRegular.fourteen, firstColor: Colors.textColor, mainText: Constants.maxWalkTimeHeader, subText: emptyString).mainText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
