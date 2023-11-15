//
//  ResetButtonCell.swift
//  RCRC
//
//  Created by Aashish Singh on 20/07/22.
//

import UIKit

class ResetButtonCell: UITableViewCell {

    @IBOutlet weak var resetButton: UIButton!
    
    var resetButtonClicked: ((TravelPreferenceModel) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        self.resetButton.setTitle(Constants.reset.localized, for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func resetButtonTapped(_ sender: UIButton) {
        let savePreferencesModel = TravelPreferenceModel(userName: UserDefaultService.getUserName(), alternativeStopsPreference: true, busTransport: true, careemTransport: false, impaired: false, maxTime: .fifteenMin, metroTransport: false, routePreference: .quickest, uberTransport: false, walkSpeed: .normal)
        resetButtonClicked?(savePreferencesModel)
    }
    
}
