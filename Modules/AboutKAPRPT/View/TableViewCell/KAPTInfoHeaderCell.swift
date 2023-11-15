//
//  KAPTInfoHeaderCell.swift
//  RCRC
//
//  Created by Aashish Singh on 20/12/22.
//

import UIKit

class KAPTInfoHeaderCell: UITableViewCell {

    @IBOutlet weak var kaptInfoImage: UIImageView!
    @IBOutlet weak var kaptImageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerLabel: LocalizedLabel!
    @IBOutlet weak var headerOpaqueView: UIView!
    @IBOutlet weak var headerTitleLabel: LocalizedLabel!
    @IBOutlet weak var headerTitleLabelBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var headerTitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerTitleTopConstraintWithoutImage: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func configureUI(){
        self.selectionStyle = .none
        self.kaptInfoImage.translatesAutoresizingMaskIntoConstraints = false
        self.headerTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.headerLabel.font = Fonts.Regular.sixteen
        self.headerTitleLabel.font = Fonts.Bold.eighteen
        kaptImageHeightConstraint.constant = 0
        updateConstraintPriority(isImageLoaded: false)
    }
    
    func configure(kaptHeaderImage: UIImage?, headerText: String, headerTitle: String) {
        if let kaptHeaderImage = kaptHeaderImage {
            let ratio = kaptHeaderImage.size.width / kaptHeaderImage.size.height
            let imageHeight = kaptInfoImage.frame.width / ratio
            let headerTextHeight = heightForLabel(text: headerText, font: Fonts.Regular.sixteen!)
            let headerTitleHeight = heightForLabel(text: headerTitle, font: Fonts.Bold.eighteen!)
            let updatedHeightWithLabel = imageHeight + headerTextHeight + headerTitleHeight
            let scaledImage = kaptHeaderImage.scalePreservingAspectRatio(targetSize: CGSize(width: self.kaptInfoImage.frame.width, height: updatedHeightWithLabel))
            kaptInfoImage.image = scaledImage
            kaptImageHeightConstraint.constant = updatedHeightWithLabel
            kaptInfoImage.layoutIfNeeded()
            self.updateConstraintPriority(isImageLoaded: true)
        }
    }
    
    func configureHeaderTextContent(descText: String?, titleText: String?) {
        headerOpaqueView.isHidden = true
        headerLabel.text = emptyString
        headerTitleLabel.text = emptyString
        headerTitleLabelBottomConstraint.constant = 0
        self.updateConstraintPriority(isImageLoaded: false)
        
        if let text = descText, text != emptyString {
            headerOpaqueView.isHidden = false
            headerLabel.text = text
        }
        
        if let titleText = titleText, titleText != emptyString {
            headerTitleLabelBottomConstraint.constant = 8
            headerTitleTopConstraint.constant = 8
            headerTitleLabel.text = titleText
            self.updateConstraintPriority(isImageLoaded: false)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func heightForLabel(text:String, font: UIFont) -> CGFloat{
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.headerLabel.frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        return label.frame.height * 0.9
    }
    
    private func updateConstraintPriority(isImageLoaded: Bool) {
        kaptImageHeightConstraint.priority = UILayoutPriority(rawValue: isImageLoaded ? 999: 250)
        headerTitleTopConstraint.priority = UILayoutPriority(rawValue: isImageLoaded ? 999: 250)
        headerTitleTopConstraintWithoutImage.priority = UILayoutPriority(rawValue: isImageLoaded ? 250: 999)
        headerOpaqueView.isHidden = !isImageLoaded
        headerTitleLabel.textColor = isImageLoaded ? Colors.white: Colors.black
        headerLabel.textColor = isImageLoaded ? Colors.white: Colors.black
    }

}
