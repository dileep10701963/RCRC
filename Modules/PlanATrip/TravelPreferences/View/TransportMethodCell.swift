//
//  TransportMethodCell.swift
//  RCRC-UI
//
//  Created by Admin on 16/04/21.
//

import UIKit

class TransportMethodCell: UITableViewCell {
    @IBOutlet weak var transportLabel: UILabel!
    @IBOutlet weak var typeOfTransportImageView: UIImageView!
    @IBOutlet weak var tickandUntickCellImageview: UIImageView!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        transportLabel.setAlignment()
    }
    
    func configure(indexPath: IndexPath, model: TravelPreferenceModel) {
        self.transportLabel.text = TransportMethodPreferences.allCases[indexPath.row - 1].transportMethodName
        self.typeOfTransportImageView.image = UIImage(named: TransportMethodPreferences.allCases[indexPath.row-1].transportTypeImages)
        switch TransportMethodPreferences.allCases[indexPath.row - 1] {
        case .bus:
            self.tickandUntickCellImageview.image = model.busTransport ?? false ? Images.tickMark: nil
        }
        
        imageTopConstraint.constant = indexPath.row == 0 ? 8 : 4
        imageBottomConstraint.constant = indexPath.row == TransportMethodPreferences.allCases.count - 1 ? 8 : 4
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
