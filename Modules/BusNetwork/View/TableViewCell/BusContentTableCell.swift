//
//  BusContentTableCell.swift
//  RCRC
//
//  Created by Aashish Singh on 21/10/22.
//

import UIKit
import PDFKit

class BusContentTableCell: UITableViewCell {

    @IBOutlet weak var titleLabel: LocalizedLabel!
    @IBOutlet weak var imageContent: UIImageView!
    @IBOutlet weak var fullScreenButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var accessoryButton: UIButton!
    @IBOutlet weak var buttonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageTopConstraint: NSLayoutConstraint!
    
    
    var cellTapped: ((UITableViewCell, UIImage) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.imageContent.image = Images.newsPlaceholder
    }
    
    private func configureUI(){
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.Regular.fifteen!,
            NSAttributedString.Key.foregroundColor: Colors.green,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
          ]
        
        let attributeString = NSMutableAttributedString(
            string: Constants.viewFullScreen.localized,
            attributes: attributes
        )
        
        titleLabel.font = Fonts.Regular.eighteen
        titleLabel.textColor = Colors.green
        
        fullScreenButton.setAttributedTitle(attributeString, for: .normal)
        self.selectionStyle = .none
        self.imageContent.translatesAutoresizingMaskIntoConstraints = false
        self.fullScreenButton.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func configure(title: String, selectedIndexPath: IndexPath?, currentIndexPath: IndexPath) {
        self.titleLabel.text = title
        self.fullScreenButton.isHidden = true
        
        if selectedIndexPath == currentIndexPath {
            accessoryButton.setBackgroundImage(Images.collapse, for: .normal)
            imageHeightConstraint.constant = 200
            imageBottomConstraint.constant = 10
            buttonHeightConstraint.constant = 21
            imageTopConstraint.constant = 10
        } else {
            accessoryButton.setBackgroundImage(Images.addExpand, for: .normal)
            imageHeightConstraint.constant = 0
            imageBottomConstraint.constant = 0
            buttonHeightConstraint.constant = 0
            imageTopConstraint.constant = 0
        }
        
    }
    
    func setupMediaContent(image: UIImage?, isImageContentCell: Bool) {
        if let image = image {
            self.imageContent.image = image
            self.fullScreenButton.isHidden = false
            if isImageContentCell {
                let ratio = image.size.width / image.size.height
                let updatedHeight = imageContent.frame.width / ratio
                imageHeightConstraint.constant = updatedHeight
                imageContent.layoutIfNeeded()
            }
        }
    }
        
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func fullScreenButtonTapped(_ sender: UIButton) {
        self.cellTapped?(self, self.imageContent.image ?? UIImage())
    }
    
}
