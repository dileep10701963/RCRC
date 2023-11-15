//
//  CountryCodeTableCell.swift
//  RCRC
//
//  Created by Bhavin Nagaria on 25/04/23.
//

import UIKit

class CountryCodeTableCell: UITableViewCell {

    @IBOutlet weak var countryCodeView: UILabel!
    @IBOutlet weak var countryCodeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        //self.contentView.semanticContentAttribute = .forceLeftToRight
        //self.countryCodeView.flipX()
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
    
    func setCountryLabel(_ countryCode: String) {
        if currentLanguage == .arabic || currentLanguage == .urdu {
            let reversedCountryCode = String(countryCode.reversed())
            countryCodeLabel.text = reversedCountryCode
            countryCodeLabel.textAlignment = .right
        } else {
            countryCodeLabel.text = countryCode
            countryCodeLabel.textAlignment = .left
        }
    }
}
