//
//  HomeWorkFavoriteTableViewCell.swift
//  RCRC
//
//  Created by Errol on 16/04/21.
//

import UIKit

class HomeWorkFavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var cellImage: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var editButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var addressLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(result: PlacesOfInterestResult) {
        let attributedContent = self.setAttributedStringToLabels(secondColor: Colors.textLightColor, mainText: result.name , subText: result.vicinity ?? emptyString)
        locationLabel.attributedText = attributedContent.mainText
        addressLabel.attributedText = attributedContent.subText
        hideEditButton()
        self.setAlignmentForLabel()
    }
    
    func configureSavedLocation(result: SavedLocation) {
        let attributedContent = self.setAttributedStringToLabels(secondColor: Colors.textLightColor, mainText: result.tag ?? emptyString , subText: result.address ?? emptyString)
        locationLabel.attributedText = attributedContent.mainText
        addressLabel.attributedText = attributedContent.subText
        showEditButton()
        self.setAlignmentForLabel()
    }
    
    func configureSavedLocationForFav(result: SavedLocation) {
        let attributedContent = self.setAttributedStringToLabels(secondColor: Colors.textLightColor, mainText: result.tag == "" || result.tag == nil ? result.location ?? "": result.tag ?? "" , subText: result.address ?? emptyString)
        locationLabel.attributedText = attributedContent.mainText
        addressLabel.attributedText = attributedContent.subText
        showEditButton()
        self.setAlignmentForLabel()
    }
    
    func configureRecentSearch(result: RecentSearch) {
        let attributedContent = self.setAttributedStringToLabels(secondColor: Colors.textLightColor, mainText: result.location ?? emptyString , subText: result.address ?? emptyString)
        locationLabel.attributedText = attributedContent.mainText
        addressLabel.attributedText = attributedContent.subText
        hideEditButton()
        self.setAlignmentForLabel()
    }
    
    private func hideEditButton() {
        editButton.isHidden = true
        editButtonWidth.constant = 0.0
    }
    
    private func showEditButton() {
        editButton.isHidden = false
        editButtonWidth.constant = 20.0
    }
    
    private func setAlignmentForLabel() {
        locationLabel.setAlignment()
        addressLabel.setAlignment()
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
    @IBAction func editButtonAction(_ sender: Any) {
    }
}

extension UITableViewCell {
    
    func setAttributedStringToLabels(firstFont: UIFont = Fonts.CodecBold.sixteen, secondFont: UIFont = Fonts.CodecRegular.fourteen, firstColor: UIColor = Colors.textColor, secondColor: UIColor = Colors.textColor, mainText: String, subText: String) -> (mainText: NSMutableAttributedString, subText: NSMutableAttributedString) {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        
        let mainAttr = NSMutableAttributedString(string: mainText, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: firstFont, NSAttributedString.Key.foregroundColor: firstColor])
        
        let subAttr = NSMutableAttributedString(string: subText, attributes: [NSAttributedString.Key.paragraphStyle: paragraphStyle, NSAttributedString.Key.font: secondFont, NSAttributedString.Key.foregroundColor: secondColor])
        
        return (mainAttr, subAttr)
    }
    
}
