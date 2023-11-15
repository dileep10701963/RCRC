//
//  PlacesOfInterestListCell.swift
//  RCRC
//
//  Created by Aashish Singh on 03/02/23.
//

import UIKit

class PlacesOfInterestListCell: UITableViewCell {

    @IBOutlet weak var titleLabel: LocalizedLabel!
    @IBOutlet weak var subtitleLabel: LocalizedLabel!
    @IBOutlet weak var favButton: UIButton!
    
    var favoriteTapped: (() -> Void)?
    private var location: SavedLocation!
    private var favoriteService: FavoriteLocationDataRepository!

    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    private func configureView() {
        favButton.setImage(Images.selectFavourites, for: .normal)
        favButton.setImage(Images.selectedFavourites, for: .selected)
        bringSubviewToFront(favButton)
    }
    
    func configure(image: UIImage? = Images.historyPlace, location: SavedLocation) {
        self.favoriteService = .shared
        self.location = location
        let attributedContent = self.setAttributedStringToLabels(secondColor: Colors.textLightColor, mainText: location.location ?? emptyString, subText: location.address ?? emptyString)
        titleLabel.attributedText = attributedContent.mainText
        subtitleLabel.attributedText = attributedContent.subText
        favButton.isSelected = isLocationFavorite(location: location)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func favButtonTapped(_ sender: UIButton) {
        if isLocationFavorite(location: location) {
            removeFavorite(location: location)
        } else {
            saveFavorite(location: location)
        }
        sender.isSelected.toggle()
    }
        
}

extension PlacesOfInterestListCell {
    
    func isLocationFavorite(location: SavedLocation) -> Bool {
        guard let favorites = favoriteService.fetchAll() else { return false }
        return favorites.contains(location)
    }

    func saveFavorite(location: SavedLocation) {
        favoriteService.create(record: location)
    }

    func removeFavorite(location: SavedLocation) {
        if isLocationFavorite(location: location) {
            favoriteService.delete(record: location)
        }
    }
}
