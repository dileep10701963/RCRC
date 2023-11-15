//
//  LanguageTableViewCell.swift
//  RCRC
//
//  Created by Admin on 06/11/23.
//

import UIKit

class LanguageTableViewCell: UITableViewCell {

    @IBOutlet weak var languageSegmentControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
