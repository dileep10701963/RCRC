//
//  BuyButtonTableViewCell.swift
//  RCRC
//
//  Created by Anjum on 09/11/23.
//

import UIKit

class BuyButtonTableViewCell: UITableViewCell {
    var buttonBuyTapped: (() -> Void)?
    @IBOutlet weak var buttonBuy: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configure()
    }
    func configure()  {
//        self.contentView.layer.addBorder(edge: .left, color: Colors.rptGreen, thickness: 0.5)
//        self.contentView.layer.addBorder(edge: .right, color: Colors.rptGreen, thickness: 0.5)
//        //self.contentView.layer.addBorder(edge: .bottom, color: Colors.rptGreen, thickness: 0.5)
//        //self.contentView.lowerTwoCornerMask(radius: 20)
//        self.contentView.layer.addBorder(edge: .bottom, color: Colors.rptGreen, thickness: 0.5)
        //self.contentView.lowerTwoCornerMask(radius: 10)
        buttonBuy.setTitle(Constants.byATicektTitle.localized, for: .normal)
        self.contentView.addBorder(edge: .bottom, color: .black, thickness: 12)
       
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func buttonBuyTapped(_ sender: UIButton) {
        buttonBuyTapped?()
    }
    
}
