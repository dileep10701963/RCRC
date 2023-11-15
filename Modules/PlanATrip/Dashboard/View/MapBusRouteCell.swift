//
//  MapBusRouteCell.swift
//  RCRC
//
//  Created by Aashish Singh on 18/05/23.
//

import UIKit

class MapBusRouteCell: UITableViewCell {

    @IBOutlet weak var buttonSelectCheckBox: UIButton!
    @IBOutlet weak var labelBusRouteNumber: UILabel!
    @IBOutlet weak var labelBusRouteStops: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI () {
        labelBusRouteNumber.font = Fonts.CodecBold.fourteen
        labelBusRouteNumber.textColor = Colors.textColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
