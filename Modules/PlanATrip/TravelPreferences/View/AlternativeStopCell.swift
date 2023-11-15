//
//  AlternativeStopCell.swift
//  RCRC
//
//  Created by Aashish Singh on 10/02/23.
//

import UIKit

class AlternativeStopCell: UITableViewCell {

    @IBOutlet weak var sortRouteLabelText: UILabel!
    @IBOutlet weak var buttonSwitch: UISwitch!
    var reloadTableView: ((UITableViewCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func buttonSwitchTapped(_ sender: UISwitch) {
        self.reloadTableView?(self)
    }
    
    
}
