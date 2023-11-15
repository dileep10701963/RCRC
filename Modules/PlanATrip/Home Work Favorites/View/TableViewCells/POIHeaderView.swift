//
//  POIHeaderView.swift
//  RCRC
//
//  Created by Aashish Singh on 26/04/23.
//

import UIKit

protocol POIHeaderViewDelegate: AnyObject {
    func buttonExpandArrowTapped(sender: UIButton)
}

class POIHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var buttonExpandArrow: UIButton!
    @IBOutlet var arrayOfImageView: [UIImageView]!

    
    static let reuseIdentifier = "POIHeaderView"
    weak var delegate: POIHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.setAlignment()
        headerLabel.textColor = .black
        self.contentView.backgroundColor = .white
        headerLabel.font = Fonts.CodecBold.nineteen
        for (index, imageView) in arrayOfImageView.enumerated() {
            arrayOfImageView[index].image = imageView.image?.setNewImageAsPerLanguage()
        }
    }
    
    func configure(headerText: String, isExpandImageVisible: Bool = true, isExpanded: Bool = false) {
        headerLabel.font = Fonts.CodecBold.sixteen
        headerLabel.text = headerText
        buttonExpandArrow.isHidden = isExpandImageVisible
        buttonExpandArrow.isSelected = isExpanded
    }
    
    @IBAction func buttonExpandArrowTapped(_ sender: UIButton) {
        delegate?.buttonExpandArrowTapped(sender: sender)
    }
    

}
