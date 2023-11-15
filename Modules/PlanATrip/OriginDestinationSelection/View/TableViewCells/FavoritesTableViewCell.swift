//
//  FavoritesTableViewCell.swift
//  RCRC
//
//  Created by Errol on 19/07/20.
//

import UIKit

class FavoritesTableViewCell: UITableViewCell {

    @IBOutlet weak var favoriteCellImage: UIImageView!
    @IBOutlet weak var favoriteLocationHeader: LocalizedLabel!
    @IBOutlet weak var favoriteLocationText: LocalizedLabel!

    let myFavPlacesImage = UIImage(named: "SelectedFavourites")

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configureCell(favoritePlace: SavedLocation) {
        self.favoriteCellImage.image = myFavPlacesImage
        let mainText = favoritePlace.location ?? emptyString
        let subText = favoritePlace.address ?? emptyString
        let attributeContent = self.setAttributedStringToLabels(mainText: mainText.localized, subText: subText.localized)
        self.favoriteLocationHeader.attributedText = attributeContent.mainText
        self.favoriteLocationText.attributedText = attributeContent.subText
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
}
