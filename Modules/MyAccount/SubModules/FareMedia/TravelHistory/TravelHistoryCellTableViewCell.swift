//
//  TravelHistoryCellTableViewCell.swift
//  RCRC
//
//  Created by Saheba Juneja on 03/05/23.
//

import UIKit

class TravelHistoryCellTableViewCell: UITableViewCell {
    
    @IBOutlet weak var stationNameLabel: UILabel!
    @IBOutlet weak var travelNumerLabel: UILabel!
    @IBOutlet weak var dateOftravelLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellConstraints(stationName: String, travelnumber:String, dateofTravel: String) {
        DispatchQueue.main.async {
            self.stationNameLabel.text = stationName
            self.travelNumerLabel.text = travelnumber
            self.dateOftravelLabel.text = dateofTravel
        }
    }
}
