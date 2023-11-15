//
//  RecentCommunicationCell.swift
//  RCRC
//
//  Created by Saheba Juneja on 16/09/22.
//

import UIKit

class RecentCommunicationCell: UITableViewCell {
    
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var requestTypeLabel: UILabel!
    @IBOutlet weak var serviceNumberLabel: UILabel!
    @IBOutlet weak var serviceTypeLabel: UILabel!
    
    var recentCommunicationItemModel: Item? {
        didSet {
            guard let recentCommunicationItemModel = recentCommunicationItemModel else {
                return
            }
            self.serviceTypeLabel.text = recentCommunicationItemModel.serviceRequestType
            self.serviceNumberLabel.text = recentCommunicationItemModel.srNumber
            self.requestTypeLabel.text = recentCommunicationItemModel.srsubType
            self.statusLabel.text = recentCommunicationItemModel.status
            self.commentsLabel.text = recentCommunicationItemModel.comments
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static var nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    static var identifier: String {
        return String(describing: self)
    }
    
}
