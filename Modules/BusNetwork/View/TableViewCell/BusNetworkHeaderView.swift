//
//  BusNetworkHeaderView.swift
//  RCRC
//
//  Created by Aashish Singh on 21/10/22.
//

import UIKit

class BusNetworkHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var headerLabel: UILabel!
    
    static let reuseIdentifier = "TravelPreferenceHeaderView"

    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.setAlignment()
    }

}
