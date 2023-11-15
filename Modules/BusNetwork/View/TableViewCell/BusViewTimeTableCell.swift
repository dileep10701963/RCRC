//
//  BusViewTimeTableCell.swift
//  RCRC
//
//  Created by Aashish Singh on 29/11/22.
//

import UIKit

class BusViewTimeTableCell: UITableViewCell {

    @IBOutlet weak var headerLabel: LocalizedLabel!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var viewTimeTableButton: UIButton!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeTableButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeTableImageView: UIImageView!
    @IBOutlet weak var timeTableButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeTableImageHeightConstraint: NSLayoutConstraint!
    var timeTableTapped: ((_ cell: UITableViewCell) -> Void)?
    var cellTapped: ((BusViewTimeTableCell) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func configureUI(){
        
        self.selectionStyle = .none
        self.viewTimeTableButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(title: String, selectedIndexPath: IndexPath?, currentIndexPath: IndexPath, isPDF: Bool = false) {
        
        headerLabel.text = title.localized
        if selectedIndexPath == currentIndexPath {
           // accessoryButton.setImage(Images.busCollapse, for: .normal)
            timeTableButtonTopConstraint.constant = 16
            timeTableButtonBottomConstraint.constant = 16
            buttonHeightConstraint.constant = 20
            viewTimeTableButton.isHidden = false
            timeTableImageView.isHidden = false
            timeTableImageHeightConstraint.constant = 20
            timeTableImageView.image = Images.timeTable
        } else {
           // accessoryButton.setImage(Images.busExpand, for: .normal)
            timeTableButtonTopConstraint.constant = 0
            timeTableButtonBottomConstraint.constant = 4
            buttonHeightConstraint.constant = 0
            viewTimeTableButton.isHidden = true
            timeTableImageView.isHidden = true
            timeTableImageHeightConstraint.constant = 0
            timeTableImageView.image = nil
        }
        
        viewTimeTableButton.setAttributedTitle(setAttributedStringOnLabel(isPDF: isPDF), for: .normal)
    }
    
    func setAttributedStringOnLabel(isPDF: Bool) -> NSAttributedString {
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: Fonts.CodecRegular.sixteen,
            .foregroundColor: Colors.newGreen,
            .underlineStyle: NSUnderlineStyle.single.rawValue
          ]
        var attributedString: NSMutableAttributedString!
        switch isPDF {
        case true:
            attributedString = NSMutableAttributedString(
                string: Constants.stage1BusMap.localized, attributes: attributes
            )
            timeTableImageView.isHidden = true
            timeTableImageHeightConstraint.constant = 0
            timeTableImageView.image = nil
        case false:
            /*let imageAttachment = NSTextAttachment()
             imageAttachment.image = Images.timeTable
             let attachmentString = NSAttributedString(attachment: imageAttachment)*/
            attributedString = NSMutableAttributedString(
                string: Constants.viewTimeTable.localized, attributes: attributes
            )
            //attributedString.append(attachmentString)
        }
        return attributedString
    }
    
    @IBAction func accessoryButtonAction(_ sender: UIButton) {
        self.cellTapped?(self)
    }
    
    @IBAction func viewTimeTableButtonTapped(_ sender: UIButton) {
        self.timeTableTapped?(self)
    }
}
