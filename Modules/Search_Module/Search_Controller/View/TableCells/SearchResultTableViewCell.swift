//
//  TableViewCell.swift
//  TwoWayBindingDemo
//
//  Created by Errol on 10/07/20.
//  Copyright © 2020 Errol. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var resultLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    var item: String? {
        didSet {
            guard let searchResult = item else { return }
            self.resultLabel.text = searchResult
        }
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }

}
