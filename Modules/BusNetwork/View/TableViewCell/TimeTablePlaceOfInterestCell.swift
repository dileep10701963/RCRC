//
//  TimeTablePlaceOfInterestCell.swift
//  RCRC
//
//  Created by Aashish Singh on 03/11/22.
//

import UIKit

class TimeTablePlaceOfInterestCell: UITableViewCell {

    @IBOutlet weak var placeOfInteresetHeaderLabel: LocalizedLabel!
    @IBOutlet weak var stackView: UIStackView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configure()
    }
    
    private func configure() {
//        placeOfInteresetHeaderLabel.font = Fonts.Bold.seventeen
//        placeOfInteresetHeaderLabel.textColor = Colors.green
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        placeOfInteresetHeaderLabel.text = Constants.keyPointsBusTimeTable
        self.selectionStyle = .none
    }
    
    func configureContent(keyPoints: String) {
        
        stackView.subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        for addedSubView in stackView.arrangedSubviews where stackView.arrangedSubviews.count > 0 {
            self.stackView.removeArrangedSubview(addedSubView)
        }
        
        let label = UILabel()
        label.numberOfLines = 0
        label.font = Fonts.CodecRegular.fifteen //Regular.seventeen
        label.textColor = Colors.black
        label.lineBreakMode = .byWordWrapping
        
        let attributedString = NSMutableAttributedString(string: keyPoints)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        attributedString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        label.attributedText = attributedString
        
        self.stackView.addArrangedSubview(label)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
