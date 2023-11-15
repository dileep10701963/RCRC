//
//  CardOptionViewController.swift
//  RCRC
//
//  Created by anand madhav on 14/03/21.
//

import UIKit

class CardOptionViewController: UIViewController {
    @IBOutlet weak var cardOptionTitleLabel: UILabel!
    @IBOutlet weak var cardOptionDescriptionLabel: UILabel!
    var isBlocked: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .cardOption)
        navigationController?.navigationBar.isHidden = true
        setUpUI()
    }

    func setUpUI() {
        if UserDefaults.standard.bool(forKey: "isDeleted") {
            cardOptionTitleLabel.text = Constants.cardDeleteText.localized
            cardOptionDescriptionLabel.text = Constants.cardDeleteDescriptionTitle.localized
        } else if UserDefaults.standard.bool(forKey: Constants.isBlockedTitle.localized) {
            cardOptionTitleLabel.text = Constants.cardBlockDetailTitle.localized
            cardOptionDescriptionLabel.text = Constants.cardBlockDescriptionTitle.localized
        } else {
            cardOptionTitleLabel.text = Constants.cardUnblockTitle.localized
            cardOptionDescriptionLabel.text = Constants.cardUnblockDescriptionTitle.localized
        }
    }

    @IBAction func doneButtonSelected() {
        navigationController?.navigationBar.isHidden = false
        self.navigationController?.popViewController(animated: true)
    }
}
