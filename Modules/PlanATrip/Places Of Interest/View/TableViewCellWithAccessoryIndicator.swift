//
//  TableViewCellWithAccessoryIndicator.swift
//  RCRC
//
//  Created by Errol on 07/07/21.
//

import UIKit

final class TableViewCellWithAccessoryIndicator: UITableViewCell {
    var cellLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Fonts.CodecRegular.fourteen
        label.setAlignment()
        return label
    }()
    
    var cellIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var cellIconArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = Colors.rptGreen
        imageView.image = Images.profileArrow
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: TableViewCellWithAccessoryIndicator.identifier)
        contentView.addSubview(cellLabel)
        contentView.addSubview(cellIcon)
        contentView.addSubview(cellIconArrow)
        
        cellIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22).isActive = true
        cellIcon.trailingAnchor.constraint(equalTo: cellLabel.leadingAnchor, constant: -12).isActive = true
        cellIcon.centerYAnchor.constraint(equalTo: cellLabel.centerYAnchor).isActive = true
        cellIcon.widthAnchor.constraint(equalToConstant: 20).isActive = true
        cellIcon.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        cellLabel.leadingAnchor.constraint(equalTo: cellIcon.trailingAnchor, constant: 12).isActive = true
        cellLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22).isActive = true
        cellLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        cellIconArrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8).isActive = true
        cellIconArrow.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        cellIconArrow.widthAnchor.constraint(equalToConstant: 12).isActive = true
        cellIconArrow.heightAnchor.constraint(equalToConstant: 16).isActive = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(text: String?, disclosureIndicatorEnabled: Bool = true, isPlaceOfInterest: Bool = false) {
        
        cellLabel.text = text
        cellIcon.image = Images.creditCard
        
        if isPlaceOfInterest {
            cellIcon.isHidden = true
            cellIconArrow.isHidden = false
            cellIcon.widthAnchor.constraint(equalToConstant: 0).isActive = true
            cellIcon.widthAnchor.constraint(equalToConstant: 0).isActive = true
            cellIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
            
            cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 42).isActive = true
            configurePlaceOfInterest()
            
        } else {
            
            cellIconArrow.isHidden = true
            cellIconArrow.widthAnchor.constraint(equalToConstant: 0).isActive = true
            cellIconArrow.widthAnchor.constraint(equalToConstant: 0).isActive = true
            cellIconArrow.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0).isActive = true
            
        }
    }
    
    func configureForCategory(text: String) {
        cellLabel.text = text
        cellIcon.isHidden = true
        cellIconArrow.isHidden = true
        cellIcon.widthAnchor.constraint(equalToConstant: 0).isActive = true
        cellIcon.widthAnchor.constraint(equalToConstant: 0).isActive = true
        cellIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 42).isActive = true
        cellLabel.font = Fonts.CodecRegular.eighteen
        cellLabel.textColor = Colors.rptGrey
        cellLabel.setAlignment()
    }

    private func configurePlaceOfInterest() {
        cellLabel.textColor = Colors.textColor
        cellLabel.font = Fonts.CodecBold.sixteen
    }
    
    static var identifier: String {
        return String(describing: self)
    }
}
