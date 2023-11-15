//
//  BusRouteNorthSouthTableViewCell.swift
//  RCRC
//
//  Created by Saheba Juneja on 01/03/23.
//

import UIKit
import Foundation


class BusRouteNorthSouthTableViewCell: UITableViewCell {
    
    enum RouteType {
        case north
        case south
        case keyFeatures
        
    }
    
    @IBOutlet weak var bottomDividerView: UIView!
    @IBOutlet weak var busRouteDataTextView: UITextView!
    @IBOutlet weak var routeBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        busRouteDataTextView.isScrollEnabled = false
        busRouteDataTextView.isEditable = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(routes: String?, routeType: RouteType) {
        bottomDividerView.isHidden = false
        switch routeType {
        case .north:
            self.routeBackgroundView.backgroundColor = Colors.northRouteGreen
        case .south:
            self.routeBackgroundView.backgroundColor = Colors.southRouteGreen
        case .keyFeatures:
            bottomDividerView.isHidden = true
            self.routeBackgroundView.backgroundColor = Colors.lightGrey
        }
        
        busRouteDataTextView.attributedText = routes?.htmlToAttributedString(font: Fonts.CodecRegular.fourteen, color: Colors.textColor)?.trimmedAttributedString()
        busRouteDataTextView.setAlignment()
        
    }
}
