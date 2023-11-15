//
//  FilterRoutesByCell.swift
//  RCRC-UI
//
//  Created by Admin on 16/04/21.
//

import UIKit

class FilterRoutesByCell: UITableViewCell {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var optionsSelectionButton: UIButton!
    @IBOutlet weak var optionsSelectionImageView: UIImageView!
    
    @IBOutlet weak var separatorBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var seperatorLabel: UILabel!
    
    var reloadTableView: ((UITableViewCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.setAlignment()
        seperatorLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func optionsSelectionTapped(_ sender: Any) {
        self.reloadTableView?(self)
    }
}
