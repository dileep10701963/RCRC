//
//  FavoriteRouteTableViewCell.swift
//  RCRC
//
//  Created by Errol on 19/02/21.
//

import UIKit

class FavoriteRouteTableViewCell: UITableViewCell {

    @IBOutlet weak var source: UILabel!
    @IBOutlet weak var destination: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var labelRouteNumber: UILabel!
    @IBOutlet weak var labelBusStop: UILabel!
    @IBOutlet weak var labelTo: UILabel!
    @IBOutlet weak var labelFrom: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.deleteButton.setAlignment()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
    
    func cellConfigure()  {
        
    }
}
