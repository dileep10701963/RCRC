//
//  RecentSearchHeaderView.swift
//  RCRC
//
//  Created by Aashish Singh on 18/05/23.
//

import Foundation
import UIKit

protocol RecentSearchHeaderViewDelegate: AnyObject {
    func deleteAllButtonPressed()
}

class RecentSearchHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var buttonClearAll: UIButton!
    
    @IBOutlet weak var recentSearchTitleLabel: UILabel!
    static let reuseIdentifier = "RecentSearchHeaderView"
    weak var delegate: RecentSearchHeaderViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonClearAll.setTitle(Constants.clearAll.localized, for: .normal)
        buttonClearAll.titleLabel?.font = Fonts.CodecBold.sixteen
        buttonClearAll.setTitleColor(Colors.textDarkColor, for: .normal)
        self.contentView.backgroundColor = .white
        
        recentSearchTitleLabel.text = Constants.recentSearch.localized
        recentSearchTitleLabel.font = Fonts.CodecBold.sixteen
        recentSearchTitleLabel.textColor = Colors.textDarkColor
    }
    
    @IBAction func buttonClearAllTapped(_ sender: UIButton) {
        delegate?.deleteAllButtonPressed()
    }
    
}
