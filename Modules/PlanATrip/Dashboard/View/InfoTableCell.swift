//
//  InfoTableCell.swift
//  RCRC
//
//  Created by Aashish Singh on 12/06/23.
//

import UIKit

class InfoTableCell: UITableViewCell {

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var answerLabel: UILabel!
    @IBOutlet weak var dividerView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configureView()
    }
    
    private func configureView() {
        //dividerView.layer.borderColor = Colors.placeHolderGray.cle
        dividerView.layer.borderWidth = 0.0
        //self.contentView.layer.borderColor = Colors.placeHolderGray.cgColor
       // self.contentView.layer.borderWidth = 1.0
       // self.infoLabel.font = Fonts.CodecBold.twelve
        //self.infoLabel.textColor = Colors.textColor
        //self.answerLabel.font = Fonts.CodecBold.twelve
       // self.answerLabel.textColor = Colors.textColor
        contentView.setCorner(radius: 10)
        
    }
    
    func configureData(model: NextBusInfoModel) {
        let name = model.number ?? emptyString
        infoLabel.text = name != emptyString ? "\(Constants.busTitle.localized) \(name)": emptyString
        answerLabel.text = model.departureTimePlanned ?? emptyString
        infoLabel.setAlignment()
        //answerLabel.textAlignment = .center
         self.infoLabel.font = Fonts.CodecBold.twelve
         self.infoLabel.textColor = Colors.textColor
         self.answerLabel.font = Fonts.CodecBold.twelve
         self.answerLabel.textColor = Colors.textColor
        
    }
    
    func configureHeader() {
        infoLabel.text = Constants.route.localized
        answerLabel.text = Constants.departureInfo.localized
        //infoLabel.textAlignment = .center
        //answerLabel.textAlignment = .center
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
