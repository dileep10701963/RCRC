//
//  SideMenuLngCell.swift
//  RCRC
//
//  Created by Aashish Singh on 16/02/23.
//

import UIKit

class SideMenuLngCell: UITableViewCell {

    @IBOutlet weak var labelArabic: UILabel!
    @IBOutlet weak var arabicBackGround: UIImageView!
    @IBOutlet weak var buttonArabic: UIButton!
    
    @IBOutlet weak var labeleng: UILabel!
    @IBOutlet weak var engBackGround: UIImageView!
    @IBOutlet weak var buttoneng: UIButton!
    
    @IBOutlet weak var cellLeftImageView: UIImageView!
    @IBOutlet weak var lngBackgroundImage: UIImageView!
    @IBOutlet weak var lngArrow: UIImageView!
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var languageLabel: UILabel!
    
    @IBOutlet weak var stackHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackTopConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        stackView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    var cellTappedEnglish: ((UITableViewCell, Languages) -> Void)?
    var cellTappedArabic: ((UITableViewCell, Languages) -> Void)?

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureCell(indexPath: IndexPath, data: [MyAccountModel], selectedIndex: Int) {
        
        lngBackgroundImage.image = Images.cellSectionBackgroundImage?.setNewImageAsPerLanguage()
        self.cellLeftImageView.image = data[indexPath.row].image?.setNewImageAsPerLanguage()
        self.languageLabel.text = data[indexPath.row].option
        
        self.engBackGround.image = currentLanguage == .english ? Images.myAccountTitleArrow?.setNewImageAsPerLanguage(): Images.cellSectionBackgroundImage?.setNewImageAsPerLanguage()
        self.arabicBackGround.image = currentLanguage == .arabic ? Images.myAccountTitleArrow?.setNewImageAsPerLanguage(): Images.cellSectionBackgroundImage?.setNewImageAsPerLanguage()
        self.labeleng.textColor = currentLanguage == .english ? Colors.white: Colors.textColor
        self.labelArabic.textColor = currentLanguage == .arabic ? Colors.white: Colors.textColor
        
        switch selectedIndex == indexPath.row {
        case true:
            self.stackView.isHidden = false
            self.stackHeightConstraint.constant = 78
            self.stackTopConstraint.constant = 8
            self.lngArrow.image = Images.dropDownArrow!
        case false:
            self.stackView.isHidden = true
            self.stackHeightConstraint.constant = 0
            self.stackTopConstraint.constant = 0
            self.lngArrow.image = Images.rightArrowGreen?.setNewImageAsPerLanguage()
        }
        
    }
    
    
    @IBAction func buttonArabicAction(_ sender: UIButton) {
        self.cellTappedArabic?(self, .arabic)
    }
    
    @IBAction func buttonEngAction(_ sender: UIButton) {
        self.cellTappedEnglish?(self, .english)
    }
    
}
