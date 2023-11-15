//
//  QuickSelectTableViewCell.swift
//  RCRC
//
//  Created by Errol on 16/07/20.
//

import UIKit

protocol QuickSelectCellDelegate: AnyObject {
    func editProfileTapped(placeType: PlaceType)
}

final class QuickSelectTableViewCell: UITableViewCell {

    @IBOutlet weak var quickSelectOptionImage: UIImageView!
    @IBOutlet weak var quickSelectOptionName: LocalizedLabel!
    @IBOutlet weak var quickSelectOptionButton: UIButton!
    @IBOutlet weak var imageViewSchool: UIImageView!
    @IBOutlet weak var heightConstraintQSImage: NSLayoutConstraint!
    @IBOutlet weak var widthConstraintQSImage: NSLayoutConstraint!
    
    weak var delegate: QuickSelectCellDelegate?
    private var placeType: PlaceType = .home
    
    override func awakeFromNib() {
        super.awakeFromNib()
        configureView()
    }

    private func configureView() {
        quickSelectOptionButton.setImage(Images.add, for: .normal)
        quickSelectOptionButton.isEnabled = false
        quickSelectOptionButton.adjustsImageWhenDisabled = false
        quickSelectOptionImage.translatesAutoresizingMaskIntoConstraints = false
    }

    func configure(text: String?, image: UIImage?, optionButtonDisabled: Bool = true) {
        quickSelectOptionName.text = text
        quickSelectOptionImage.image = image
        imageViewSchool.isHidden = true
        quickSelectOptionButton.isHidden = false
        let image = optionButtonDisabled ? Images.profileArrow: Images.add
        quickSelectOptionButton.tintColor = Colors.buttonTintColor
        quickSelectOptionButton.setImage(image, for: .normal)
    }
    
    func configureForSchool(text: String?, image: UIImage?, placeType: PlaceType) {
        imageViewSchool.isHidden = false
        quickSelectOptionButton.isHidden = true
        quickSelectOptionName.text = text
        quickSelectOptionImage.image = image
        quickSelectOptionButton.setImage(Images.tripFav, for: .normal)
        heightConstraintQSImage.constant = 24
        widthConstraintQSImage.constant = 24
        
        switch placeType {
        case .home:
            if let homeData = HomeLocationsDataRepository.shared.fetchAll(), homeData.count > 0 {
                imageViewSchool.image = Images.editProfile
            } else {
                imageViewSchool.image = Images.tripFav
            }
        case .work:
            if let workData = WorkLocationsDataRepository.shared.fetchAll(), workData.count > 0 {
                imageViewSchool.image = Images.editProfile
            } else {
                imageViewSchool.image = Images.tripFav
            }
        default:
            break
        }
        addingActionToEditIcon()
        self.placeType = placeType
    }
    
    private func addingActionToEditIcon() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(QuickSelectTableViewCell.tapFunction))
        imageViewSchool.isUserInteractionEnabled = true
        imageViewSchool.addGestureRecognizer(tapGesture)
    }

    @objc func tapFunction(sender:UITapGestureRecognizer) {
        delegate?.editProfileTapped(placeType: placeType)
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
}
