//
//  TravelPreferenceHeaderView.swift
//  RCRC-UI
//
//  Created by Admin on 16/04/21.
//

import UIKit

class TravelPreferenceHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet var arrayImageView: [UIImageView]!
    
    static let reuseIdentifier = "TravelPreferenceHeaderView"

    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.setAlignment()
        self.contentView.backgroundColor = .white
        self.backgroundColor = .white
        for (index, imageView) in arrayImageView.enumerated() {
            arrayImageView[index].image = imageView.image?.setNewImageAsPerLanguage()
        }
    }
}
