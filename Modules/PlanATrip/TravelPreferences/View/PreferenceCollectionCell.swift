//
//  PreferenceCollectionCell.swift
//  RCRC
//
//  Created by Aashish Singh on 02/05/23.
//

import UIKit

class PreferenceCollectionCell: UICollectionViewCell {

    @IBOutlet weak var labelText: UILabel!
    @IBOutlet weak var buttonCheckBox: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(value: String) {
        labelText.text = value
        labelText.setAlignment()
    }
    
}
