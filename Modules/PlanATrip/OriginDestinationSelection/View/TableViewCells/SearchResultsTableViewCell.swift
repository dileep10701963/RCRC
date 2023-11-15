//
//  SearchResultTableViewCell.swift
//  RCRC
//
//  Created by Errol on 16/07/20.
//

import UIKit

class SearchResultsTableViewCell: UITableViewCell {

    @IBOutlet weak var searchResult: LocalizedLabel!
    @IBOutlet weak var locationImage: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    var stopResult: Location? {
        didSet {
            guard let stopResult = stopResult else {
                return
            }
            if let latitude = stopResult.coord?[safe: 0], let longitude = stopResult.coord?[safe: 1] {
                let data = SavedLocation(location: stopResult.name, address: stopResult.name, id: stopResult.id, latitude: latitude, longitude: longitude, type: Constants.stop)
                if isLocationFavorite(location: data) {
                    self.favoriteButton.setImage(Images.addedToFavorite, for: .normal)
                } else {
                    self.favoriteButton.setImage(Images.addToFavorite, for: .normal)
                }
            }
            self.searchResult.text = stopResult.name
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    @IBAction func addFavoriteButtonTapped(_ sender: UIButton) {
        guard let stopResult = stopResult else {
            return
        }
        if sender.currentImage == Images.addToFavorite {
            saveFavorite(location: SavedLocation(location: stopResult.name, address: stopResult.name, id: stopResult.id, latitude: stopResult.coord?[safe: 0], longitude: stopResult.coord?[safe: 1], type: Constants.stop))
            self.favoriteButton.setImage(Images.addedToFavorite, for: .normal)
        } else {
            removeFavorite(location: SavedLocation(location: stopResult.name, address: stopResult.name, id: stopResult.id, latitude: stopResult.coord?[safe: 0], longitude: stopResult.coord?[safe: 1], type: Constants.stop))
            self.favoriteButton.setImage(Images.addToFavorite, for: .normal)
        }
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

extension SearchResultsTableViewCell {

    func isLocationFavorite(location: SavedLocation) -> Bool {
        if let savedData = FavoriteLocationDataRepository.shared.fetchAll(), savedData.filter({
            return $0 == location
        }).isNotEmpty {
            return true
        }
        return false
    }

    func saveFavorite(location: SavedLocation) {
        FavoriteLocationDataRepository.shared.create(record: location)
    }

    func removeFavorite(location: SavedLocation) {
        if isLocationFavorite(location: location) {
            FavoriteLocationDataRepository.shared.delete(record: location)
        }
    }
}
