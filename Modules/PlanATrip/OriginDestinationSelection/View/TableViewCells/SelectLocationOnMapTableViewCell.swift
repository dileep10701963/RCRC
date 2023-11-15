//
//  BasicTableViewCell.swift
//  RCRC
//
//  Created by Errol on 16/07/20.
//

import UIKit

class SelectLocationOnMapTableViewCell: UITableViewCell {

    @IBOutlet weak var selectLocationOnMapButton: UIButton!
    @IBOutlet weak var buttonTitleLabel: UILabel!

    weak var delegate: QuickSelectionDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.bringSubviewToFront(selectLocationOnMapButton)
        self.selectionStyle = .none
        configure()
    }
    
    func configure() {
        buttonTitleLabel.font = Fonts.CodecRegular.nineteen
        buttonTitleLabel.text = Constants.selectLocationButtonTitle.localized
        buttonTitleLabel.setAlignment()
    }

    @IBAction func selectLocationOnMapTapped(_ sender: UIButton) {
        delegate?.selectLocationOnMapTapped()
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
