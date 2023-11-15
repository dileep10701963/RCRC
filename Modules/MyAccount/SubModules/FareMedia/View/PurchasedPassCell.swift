//
//  PurchasedPassCell.swift
//  RCRC
//
//  Created by Errol on 03/08/21.
//

import UIKit

final class PurchasedPassCell: UITableViewCell {
    var cellLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Fonts.RptaSignage.eighteen
        label.setAlignment()
        return label
    }()

    var select: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: PurchasedPassCell.identifier)
        contentView.addSubview(cellLabel)
        cellLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 22).isActive = true
        cellLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22).isActive = true
        cellLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(viewModel: PurchasedPassCellViewModel) {
        cellLabel.text = viewModel.passName
        select = viewModel.select
        accessoryType = .disclosureIndicator
    }

    static var identifier: String {
        return String(describing: self)
    }
}
