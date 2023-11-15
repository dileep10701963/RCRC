//
//  FareMediaHeaderView.swift
//  RCRC
//
//  Created by Aashish Singh on 17/12/22.
//

import UIKit

class FareMediaHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var headerLabel: UILabel!

    static let reuseIdentifier = "FareMediaHeaderView"
    let myTicketImage = UIImage(named: "MyTickets")
    let newTicketImage = UIImage(named: "NewTicket")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        headerLabel.textColor = .black
        self.contentView.backgroundColor = .clear
        headerLabel.font = Fonts.CodecBold.sixteen
    }
    
    func configure(available: [FareMediaAvailableProduct], purchased: [FareMediaPurchasedProduct], section: Int) {
        if available.isNotEmpty, purchased.isNotEmpty {
            headerLabel.text = section == 0 ? Constants.mypurchasedPass.localized : Constants.purchaseNewPass.localized
        } else if available.isNotEmpty, purchased.isEmpty {
            headerLabel.text = Constants.purchaseNewPass.localized
        } else if available.isEmpty, purchased.isNotEmpty {
            headerLabel.text = Constants.mypurchasedPass.localized
        }
    }
}
