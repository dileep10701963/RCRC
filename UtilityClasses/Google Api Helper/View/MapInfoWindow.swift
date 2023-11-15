//
//  MapInfoWindow.swift
//  MapInfoWindow
//
//  Created by Ganesh Shinde on 11/11/2020.
//

import UIKit

protocol MarkerDelegate: AnyObject {
    func addLocation()
}

class MapInfoWindow: UIView {

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var borderView: UIView!
    
    
    weak var delegate: MarkerDelegate?

    class func instanceFromNib() -> MapInfoWindow {
        return UINib(nibName: "MapInfoWindow", bundle: nil).instantiate(withOwner: self, options: nil).first as? MapInfoWindow ?? MapInfoWindow()
    }

    @IBAction func addButtonTapped(_ sender: UIButton) {
        delegate?.addLocation()
    }
}
