//
//  RcrcMyTicketsCell.swift
//  RCRC
//
//  Created by Saheba Juneja on 18/01/23.
//

import UIKit

class RcrcMyTicketsCell: UITableViewCell {
   
    @IBOutlet weak var passCost: UILabel!
    @IBOutlet weak var passDescription: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()
        passDescription.setAlignment()
        passCost.setAlignment()
        arrowImage.image = UIImage(named: "right_arrow")?.setNewImageAsPerLanguage()
        self.selectionStyle = .none
    }
    var select: (() -> Void)?
    
    func configure(viewModel: PurchasedPassCellViewModel) {
        passDescription.text = viewModel.passName
        
        if let productPrice = Int(viewModel.passCost ?? "0") {
            let price = (productPrice/100)
            passCost.text = "\(price)\(Constants.currencyTitle.localized)"
        } else {
            passCost.text = "\(String(describing: viewModel.passCost))\(Constants.currencyTitle.localized)"
        }
        
        select = viewModel.select
    }

    static var identifier: String {
        return String(describing: self)
    }
}
