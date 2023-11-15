//
//  DatePickerCell.swift
//  RCRC
//
//  Created by Aashish Singh on 20/07/22.
//

import UIKit

class DatePickerCell: UITableViewCell {
    
    let datePicker = UIDatePicker()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.maximumDate = Date()
        datePicker.datePickerMode = .date
        
        // Add the UI components
        contentView.addSubview(datePicker)
        
        // Set any attributes of your UI components here.
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            datePicker.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            datePicker.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            datePicker.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            datePicker.heightAnchor.constraint(equalToConstant: self.datePicker.frame.height)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
