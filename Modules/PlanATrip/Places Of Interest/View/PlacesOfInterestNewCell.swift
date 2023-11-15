//
//  PlacesOfInterestNewCell.swift
//  RCRC
//
//  Created by Aashish Singh on 01/02/23.
//

import UIKit

class PlacesOfInterestNewCell: UITableViewCell {

    @IBOutlet weak var sectionText: UILabel!
    @IBOutlet var arrayImageView: [UIImageView]!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        sectionText.setAlignment()
        sectionText.text = Constants.placesOfInterest.localized
        for (index, imageView) in arrayImageView.enumerated() {
            arrayImageView[index].image = imageView.image?.setNewImageAsPerLanguage()
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    func configureCell(text: String) {
        sectionText.text = text
    }
    
}
