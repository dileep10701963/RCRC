//
//  SlideMenuMyAccountCell.swift
//  RCRC
//
//  Created by Aashish Singh on 16/02/23.
//

import UIKit

class SlideMenuMyAccountCell: UITableViewCell {

    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var number: UILabel!
    @IBOutlet weak var emailID: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureUserDetail(model: ProfileModel?) {
        if let profileModel = model {
            emailID.text = profileModel.mail
            number.text = profileModel.phone
            userName.text = "\(profileModel.name ?? emptyString) \(profileModel.surname ?? emptyString)"
        } else {
            emailID.text = "--"
            number.text = "--"
            userName.text = "--"
        }
    }
    
}
