//
//  FriendlyStopCell.swift
//  RCRC-UI
//
//  Created by Admin on 16/04/21.
//

import UIKit

class FriendlyStopCell: UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var mobilityImpairedSwitch: UISwitch!
    
    var mobilityImpairedSwitchTap: ((UISwitch) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        headerLabel.setAlignment()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func mobilityImpairedSwitchTapped(_ sender: UISwitch) {
        self.mobilityImpairedSwitchTap?(sender)
    }
    

}
