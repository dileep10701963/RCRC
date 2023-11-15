//
//  PurchaseNewPassCell.swift
//  RCRC
//
//  Created by Errol on 03/08/21.
//

import UIKit

final class PurchaseNewPassCell: UITableViewCell {
    let disclosureIndicatorImage = UIImage(named: "WhiteDisclosureIndicator")
    let cellBackgroundImage = UIImage(named: "CellBackgroundImage")

    var passDescription: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Fonts.CodecRegular.sixteen
        label.setAlignment()
        return label
    }()

    var passCost: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.font = Fonts.CodecRegular.sixteen
        label.textAlignment = currentLanguage == .english ? .right : .left
        return label
    }()
    
    var passDescriptionBackgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "CellBackgroundImage")
        return imageView
    }()
    

    var select: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: PurchaseNewPassCell.identifier)
        contentView.addSubview(passDescriptionBackgroundImageView)
        contentView.addSubview(passDescription)
        contentView.addSubview(passCost)
        
        passDescription.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 90).isActive = true
        passDescription.trailingAnchor.constraint(equalTo: passCost.leadingAnchor, constant: -10).isActive = true
        passDescription.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        
        passDescriptionBackgroundImageView.heightAnchor.constraint(equalToConstant: 35).isActive = true
        passDescriptionBackgroundImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 55).isActive = true
        passDescriptionBackgroundImageView.trailingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0).isActive = true
        passDescriptionBackgroundImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
        passCost.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -22).isActive = true
        passCost.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    func configure(viewModel: PurchaseNewPassCellViewModel) {
        passDescriptionBackgroundImageView.backgroundColor = .green
        passDescription.text = viewModel.passDescription
        if let productPrice = Int(viewModel.passCost ?? "0") {
            passCost.text = "\(productPrice / 100) SAR"
        } else {
            passCost.text = "\(viewModel.passCost ?? "0") SAR"
        }
        select = viewModel.select
    }

    static var identifier: String {
        return String(describing: self)
    }
}
