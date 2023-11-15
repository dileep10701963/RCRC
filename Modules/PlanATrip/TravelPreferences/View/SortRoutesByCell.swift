//
//  SortRoutesByCell.swift
//  RCRC
//
//  Created by Sagar Tilekar on 30/04/21.
//

import UIKit

class SortRoutesByCell: UITableViewCell {

    @IBOutlet weak var optionsSelectionButton: UIButton!
    @IBOutlet weak var sortRouteByLabel: UILabel!
    @IBOutlet weak var separatorLabel: UILabel!
    @IBOutlet weak var separatorBottomConstraint: NSLayoutConstraint!
    
    var reloadSortByTableView: ((UITableViewCell) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        sortRouteByLabel.setAlignment()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func optionsSelectedButtonTapped(_ sender: Any) {
        self.reloadSortByTableView?(self)
    }
}
