//
//  RecentSearchTableViewCell.swift
//  RCRC
//
//  Created by Errol on 16/07/20.
//

import UIKit

enum ParentScreenController {
    case RouteSelectionView
    case none
}

final class RecentSearchTableViewCell: UITableViewCell {

    @IBOutlet weak var recentSearchImage: UIImageView!
    @IBOutlet weak var recentSearchLocationLabel: LocalizedLabel!
    @IBOutlet weak var recentSearchAddressLabel: LocalizedLabel!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var recentSearchSmallIcon: UIImageView!
    
    @IBOutlet weak var favouriteBtnWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var favBtnLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var recentSearchIconWidth: NSLayoutConstraint!
    
    @IBOutlet weak var locationLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabelCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationLabelIconTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var recentSearchImageTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var labelHorizontalConstraint: NSLayoutConstraint!
    
    var favoriteTapped: (() -> Void)?
    private var location: SavedLocation!
    private var favoriteService: FavoriteLocationDataRepository!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        configureView()
    }

    private func configureView() {
        favoriteButton.setImage(Images.addToFavorite, for: .normal)
        favoriteButton.setImage(Images.addedToFavorite, for: .selected)
        bringSubviewToFront(favoriteButton)
        recentSearchAddressLabel.lineBreakMode = .byWordWrapping
        recentSearchAddressLabel.numberOfLines = 2
        favoriteButton.translatesAutoresizingMaskIntoConstraints = false
        recentSearchImage.translatesAutoresizingMaskIntoConstraints = false
    }

    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }

    func configure(image: UIImage? = Images.recentSearchNew, location: SavedLocation, screenName: ParentScreenController) {
        
        recentSearchLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.favoriteService = .shared
        self.location = location
        //recentSearchImage.image = image
        recentSearchSmallIcon.image = image
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 3
        let addressAtrr = NSMutableAttributedString(string: location.location ?? emptyString, attributes: [NSAttributedString.Key.foregroundColor: Colors.textColor, NSMutableAttributedString.Key.font: Fonts.CodecRegular.sixteen, NSAttributedString.Key.paragraphStyle: paragraphStyle])
        recentSearchLocationLabel.attributedText = addressAtrr
        
        recentSearchImage.isHidden = false
        recentSearchSmallIcon.isHidden = true        
        favoriteButton.isSelected = isLocationFavorite(location: location)
        recentSearchIconWidth.constant = 52
        
        if screenName == .RouteSelectionView {
            recentSearchLocationLabel.numberOfLines = 1
            recentSearchAddressLabel.numberOfLines = 1
            favoriteButton.isHidden = true
            recentSearchImage.isHidden = true
            recentSearchSmallIcon.isHidden = false
            
            favBtnLeadingConstraint.constant = 0
            favouriteBtnWidthConstraint.constant = 0
            recentSearchIconWidth.constant = 22
            
            recentSearchAddressLabel.adjustsFontSizeToFitWidth = false
            recentSearchAddressLabel.lineBreakMode = .byTruncatingTail
            recentSearchLocationLabel.adjustsFontSizeToFitWidth = false
            recentSearchLocationLabel.lineBreakMode = .byTruncatingTail
            locationLabelIconTopConstraint.priority = UILayoutPriority(rawValue: 250)
            labelHorizontalConstraint.priority = UILayoutPriority(rawValue: 999)
        }
        
    }
    
    func updateUIForStopFinderResult(location: SavedLocation) {
        self.favoriteButton.isHidden = true
        if location.address ?? emptyString == emptyString {
            locationLabelIconTopConstraint.priority = UILayoutPriority(rawValue: 250)
            locationLabelTopConstraint.priority = UILayoutPriority(rawValue: 250)
            recentSearchImageTopConstraint.priority = UILayoutPriority(rawValue: 999)
            locationLabelCenterConstraint.priority = UILayoutPriority(rawValue: 999)
        } else {
            locationLabelTopConstraint.priority = UILayoutPriority(rawValue: 999)
            locationLabelIconTopConstraint.priority = UILayoutPriority(rawValue: 999)
            locationLabelCenterConstraint.priority = UILayoutPriority(rawValue: 250)
            recentSearchImageTopConstraint.priority = UILayoutPriority(rawValue: 250)
        }
    }

    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        if isLocationFavorite(location: location) {
            removeFavorite(location: location)
        } else {
            saveFavorite(location: location)
        }
        sender.isSelected.toggle()
        favoriteTapped?()
    }
}

extension RecentSearchTableViewCell {
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
