//
//  ProfileTableViewCell.swift
//  RCRC
//
//  Created by anand madhav on 20/07/20.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var descriptionTextField: UITextField?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(profileListArray: [String], profileDescriptionArray: [String], indexPath: IndexPath) {
        self.imageView?.contentMode = .scaleAspectFit
        self.titleLabel?.text = profileListArray[indexPath.row]
        self.descriptionTextField?.text = profileDescriptionArray[indexPath.row]
        self.descriptionTextField?.placeholder = profileListArray[indexPath.row]
        self.titleLabel?.setAlignment()
        self.descriptionTextField?.setAlignment()
        self.textLabel?.textColor = UIColor(
            red: 39.0/255.0,
            green: 95.0/255.0,
            blue: 53.0/255.0,
            alpha: 1.0)
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
