//
//  ServerChatTableViewCell.swift
//  RCRC
//
//  Created by pcadmin on 09/04/21.
//

import UIKit

class ServerChatTableViewCell: UITableViewCell {

    @IBOutlet weak var messageTimeLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var messageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.cornerRadius = 10
        messageView.backgroundColor = Colors.lightGreen
        messageTimeLabel.textAlignment = .right
        messageView.borderWidth = 0.5
        messageView.borderColor = Colors.shadowGray
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
