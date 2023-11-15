//
//  ListTableViewCell.swift
//  RCRC
//
//  Created by Admin on 06/11/23.
//

import UIKit

class ListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var historyNameLabel: UILabel!
    @IBOutlet weak var historyImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        historyNameLabel.setAlignment()
        historyImageView.setNewImageAsPerLanguage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
