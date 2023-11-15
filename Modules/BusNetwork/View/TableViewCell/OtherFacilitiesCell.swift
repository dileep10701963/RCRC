//
//  OtherFacilitiesCell.swift
//  RCRC
//
//  Created by Aashish Singh on 26/10/22.
//

import UIKit

class OtherFacilitiesCell: UITableViewCell {

    @IBOutlet weak var otherFacilityLabel: UILabel!
    @IBOutlet weak var otherFacilityDescriptionLabel: UILabel!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    func configure() {
        otherFacilityDescriptionLabel.setAlignment()
        otherFacilityDescriptionLabel.font = Fonts.Regular.eighteen
        otherFacilityDescriptionLabel.textColor = Colors.green
        
        otherFacilityLabel.setAlignment()
        otherFacilityLabel.font = Fonts.Bold.twentyOne
        otherFacilityLabel.textColor = Colors.green
        
        otherFacilityDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(title: String, description: String, selected: IndexPath?, current: IndexPath) {
        self.otherFacilityLabel.text = title
        if selected == current {
            accessoryButton.setBackgroundImage(Images.collapse, for: .normal)
            self.otherFacilityDescriptionLabel.text = description
            self.bottomConstraint.constant = 8
        } else {
            accessoryButton.setBackgroundImage(Images.addExpand, for: .normal)
            self.otherFacilityDescriptionLabel.text = emptyString
            self.bottomConstraint.constant = 0
        }
    
    }
    
}
