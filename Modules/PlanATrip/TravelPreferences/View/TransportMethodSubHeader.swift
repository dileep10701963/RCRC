//
//  TransportMethodSubHeader.swift
//  RCRC-UI
//
//  Created by Admin on 16/04/21.
//

import UIKit

class TransportMethodSubHeader: UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.headerLabel.attributedText = self.setAttributedStringToLabels(firstFont: Fonts.CodecRegular.fourteen, firstColor: Colors.textLightColor, mainText: Constants.headerTextTransport.localized, subText: emptyString).mainText
        headerLabel.setAlignment()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
