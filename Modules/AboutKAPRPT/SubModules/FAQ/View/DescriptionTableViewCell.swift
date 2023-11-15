//
//  DescriptionTableViewCell.swift
//  RCRC
//
//  Created by anand madhav on 11/08/20.
//

import UIKit

class DescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var answerLabelLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var answerLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var redirectioButtonLink: UILabel!
    
    @IBOutlet weak var textViewAttribute: UITextView!
    
    var link: String = ""

    override func awakeFromNib() {
        super.awakeFromNib()
        textViewAttribute.translatesAutoresizingMaskIntoConstraints = false
        self.selectionStyle = .none
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
    
    func configure(_ answer: String?, linkText: String) {
        let content = answer?.htmlToAttributedString(font: Fonts.CodecNews.fourteen, color: Colors.textGray)?.trimmedAttributedString()
        textViewAttribute.attributedText = content
        textViewAttribute.setAlignment()
        link = linkText
        if redirectioButtonLink != nil {
            redirectioButtonLink.removeFromSuperview()
        }
        
        textViewAttribute.dataDetectorTypes = [.link]
        textViewAttribute.isUserInteractionEnabled = true
        textViewAttribute.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue]
        if linkText != emptyString {
            textViewAttribute.isUserInteractionEnabled = false
            textViewAttribute.linkTextAttributes = [NSAttributedString.Key.foregroundColor: Colors.textGray]
        }
    }
    
    func configureForAboutBus(_ content: String?) {
        textViewAttribute.attributedText = content?.htmlToAttributedString(font: Fonts.CodecRegular.sixteen, color: Colors.textColor)
        answerLabelLeadingConstraint.constant = 24
        answerLabelTrailingConstraint.constant = 24
        textViewAttribute.dataDetectorTypes = [.link]
        textViewAttribute.isUserInteractionEnabled = true
        textViewAttribute.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.blue]

        textViewAttribute.setAlignment()
    }
        
    @IBAction func buttonLinkTapped(_ sender: UIButton) {
        if let appURL = URL(string: URLs.ApplicationSharing.riyadhbus) {
            let application = UIApplication.shared
            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                application.open(appURL)
            }
        }
    }
    
}

extension NSMutableAttributedString {

    public func setAsLink(textToFind:String, linkURL:String) -> Bool {
        let foundRange = self.mutableString.range(of: textToFind)
        if foundRange.location != NSNotFound {
            self.addAttribute(.link, value: linkURL, range: foundRange)
            return true
        }
        return false
    }
}
