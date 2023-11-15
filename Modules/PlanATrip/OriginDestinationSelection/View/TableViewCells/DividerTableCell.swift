//
//  DividerTableCell.swift
//  RCRC
//
//  Created by Aashish Singh on 25/01/23.
//

import UIKit

class DividerTableCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
