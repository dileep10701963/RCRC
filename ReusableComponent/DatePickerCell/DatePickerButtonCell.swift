//
//  DatePickerButtonCell.swift
//  RCRC
//
//  Created by Aashish Singh on 20/07/22.
//

import UIKit

class DatePickerButtonCell: UITableViewCell {

    let label = UILabel()
    var imageIcon = UIImageView()
    let resetButton = UIButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // UIImage View
        imageIcon = UIImageView(image: UIImage(named: "walk-1"))
        
        // UILabel
        label.text = Constants.setMaximumDuration
        label.textColor = .black
        label.font = Fonts.RptaSignage.sixteen
        
        // UIButton
        resetButton.setTitle(Constants.reset, for: .normal)
        resetButton.setTitleColor(Colors.weatherBlue, for: .normal)
        resetButton.titleLabel?.font = Fonts.RptaSignage.fifteen
        
        // Add the UI components
        contentView.addSubview(imageIcon)
        contentView.addSubview(label)
        contentView.addSubview(resetButton)
        
        // Set any attributes of your UI components here.
        imageIcon.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        resetButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            imageIcon.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            imageIcon.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            imageIcon.heightAnchor.constraint(equalToConstant: 34),
            imageIcon.widthAnchor.constraint(equalToConstant: 34),
            
            label.leadingAnchor.constraint(equalTo: imageIcon.trailingAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: imageIcon.bottomAnchor),
            label.topAnchor.constraint(equalTo: imageIcon.topAnchor),
            
            resetButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            resetButton.topAnchor.constraint(equalTo: imageIcon.topAnchor),
            resetButton.bottomAnchor.constraint(equalTo: imageIcon.bottomAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
