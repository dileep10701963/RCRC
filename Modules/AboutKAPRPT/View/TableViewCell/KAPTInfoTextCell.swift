//
//  KAPTInfoTextCell.swift
//  RCRC
//
//  Created by Aashish Singh on 21/12/22.
//

import UIKit

class KAPTInfoTextCell: UITableViewCell {

    @IBOutlet weak var infoTextLabel: LocalizedLabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var labelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var stackBottomConstraint: NSLayoutConstraint!
    
    private var buttonHyperLinkContents: [(String, String)] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureUI()
    }
    
    private func configureUI() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        infoTextLabel.translatesAutoresizingMaskIntoConstraints = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(cellTextContent: String, keyPoints: [String]) {
        labelBottomConstraint.constant = 12
        stackBottomConstraint.constant = 0
        infoTextLabel.font = Fonts.Regular.sixteen
        infoTextLabel.text = cellTextContent
        for keyPoint in keyPoints {
            self.configureContent(keyPoints: keyPoint, font: Fonts.Bold.eighteen!)
        }
    }
    
    private func configureContent(keyPoints: String, font: UIFont) {
        
        stackView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        for addedSubView in stackView.arrangedSubviews where stackView.arrangedSubviews.count > 0 {
            self.stackView.removeArrangedSubview(addedSubView)
        }
        
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Fonts.Bold.twenty
        label.textColor = Colors.green
        label.lineBreakMode = .byWordWrapping
        label.text = keyPoints
        self.stackView.addArrangedSubview(label)
    }
    
    func configureContentForButtonLink(buttonContents: [(String, String)], tag: Int) {
        
        stackView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        for addedSubView in stackView.arrangedSubviews where stackView.arrangedSubviews.count > 0 {
            self.stackView.removeArrangedSubview(addedSubView)
        }
        
        buttonHyperLinkContents = buttonContents
        for buttonContent in buttonContents {
            if buttonContent.1 != emptyString {
                let buttonContent = buttonAttributedStringWithHeight(buttonText: buttonContent.0)
                let button = UIButton(frame: CGRect(x: 0, y: 0, width: self.stackView.frame.width, height: buttonContent.1))
                button.tag = tag
                button.titleLabel?.font = Fonts.Regular.sixteen
                button.setContentHorizontalAlignment()
                button.setAttributedTitle(buttonContent.0, for: UIControl.State.normal)
                button.addTarget(self, action: #selector(hyperLinkClicked(sender:)), for: .touchUpInside)
                self.stackView.addArrangedSubview(button)
            } else {
                self.infoTextLabel.text = buttonContent.0
                self.infoTextLabel.setAlignment()
                self.infoTextLabel.font = Fonts.Regular.twenty
                self.labelBottomConstraint.constant = 8
            }
        }
    }
    
    private func buttonAttributedStringWithHeight(buttonText: String) -> (NSMutableAttributedString, CGFloat) {
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: Fonts.Regular.sixteen!,
            NSAttributedString.Key.foregroundColor: Colors.buttonHyperLink,
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
          ]
        
        let attributeString = NSMutableAttributedString(
            string: buttonText,
            attributes: attributes
        )
        
        let constraintRect = CGSize(width: self.stackView.frame.width, height: .greatestFiniteMagnitude)
        let boundingBox = attributeString.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
            
        return (attributeString, ceil(boundingBox.height))
    }
    
    @objc func hyperLinkClicked(sender: UIButton) {
        if let url = buttonHyperLinkContents.first(where: {$0.0 == sender.titleLabel?.text ?? emptyString}) {
            ApplicationSchemes.shared.openInBrowser(url.1)
        }
    }
    
}
