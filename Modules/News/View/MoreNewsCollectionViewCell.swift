//
//  MoreNewsCollectionViewCell.swift
//  RCRC
//
//  Created by Errol on 01/03/21.
//

import UIKit

class MoreNewsCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsTime: UILabel!
    @IBOutlet weak var newsImage: UIImageView!

    var onReuse: () -> Void = {}

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onReuse()
    }

    override func layoutSubviews() {
        newsTitle.setAlignment()
        newsTime.setAlignment()
    }
}
