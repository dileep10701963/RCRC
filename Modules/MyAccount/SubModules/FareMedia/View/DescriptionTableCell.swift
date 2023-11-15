//
//  DescriptionTableCell.swift
//  RCRC
//
//  Created by Bhavin Nagaria on 04/05/23.
//

import UIKit

class DescriptionTableCell: UITableViewCell {

    @IBOutlet weak var recordDateValueLabel: UILabel!
    @IBOutlet weak var paymentTypeNameValueLabel: UILabel!
    @IBOutlet weak var productValueLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        recordDateValueLabel.setAlignment()
        priceLabel.setAlignment()
        paymentTypeNameValueLabel.setAlignment()
        productValueLabel.setAlignment()
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
    
    func configure(_ model: PurchaseHistoryModel?) {
        let dateInresponse = model?.recordDate?.toDateLocalEn(timeZone: .AST) ?? Date()
        let formattedDateString = dateInresponse.toString(withFormat: Date.dateTimeHistoryFull, timeZone: .AST)
        recordDateValueLabel.text = formattedDateString
            
        if let price = model?.amountPaid {
            priceLabel.text = "\(String(format: "%.1f",price)) \(Constants.currencyTitle.localized)"
        } else {
            priceLabel.text = "0.0"
        }
        paymentTypeNameValueLabel.text = model?.paymentTypeName?.localized
        productValueLabel.text = model?.product?.localized
    }
}
