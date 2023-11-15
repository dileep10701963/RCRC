//
//  PlacesOfInterestCell.swift
//  RCRC
//
//  Created by pcadmin on 25/06/21.
//

import UIKit

final class PlacesOfInterestCell: UITableViewCell {
    var cellLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = Fonts.CodecRegular.seventeen
        label.text = Constants.placesOfInterest.localized
        label.setAlignment()
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: PlacesOfInterestCell.identifier)
        contentView.addSubview(cellLabel)
        cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22).isActive = true
        cellLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22).isActive = true
        cellLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        accessoryType = .disclosureIndicator
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    static var identifier: String {
        return String(describing: self)
    }
}
