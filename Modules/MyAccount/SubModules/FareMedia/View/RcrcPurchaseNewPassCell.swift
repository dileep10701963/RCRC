//
//  RcrcPurchaseNewPassCell.swift
//  RCRC
//
//  Created by Saheba Juneja on 18/01/23.
//

import UIKit

class RcrcPurchaseNewPassCell: UITableViewCell {
    let disclosureIndicatorImage = UIImage(named: "WhiteDisclosureIndicator")
    let cellBackgroundImage = UIImage(named: "CellBackgroundImage")
    
    @IBOutlet weak var passCost: UILabel!
    @IBOutlet weak var passDescription: UILabel!
    @IBOutlet weak var arrowImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        arrowImage.image = UIImage(named: "right_arrow")?.setNewImageAsPerLanguage()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    var select: (() -> Void)?

    func configure(viewModel: PurchaseNewPassCellViewModel) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        passDescription.text = viewModel.passDescription ?? ""
        if let productPrice = Int(viewModel.passCost ?? "0") {
            let price = (productPrice/100)
            passCost.text = "\(price)\(Constants.currencyTitle.localized)"
        } else {
            passCost.text = "\(String(describing: viewModel.passCost))\(Constants.currencyTitle.localized)"
        }
        passCost.setAlignment()
        passDescription.setAlignment()
        select = viewModel.select
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
