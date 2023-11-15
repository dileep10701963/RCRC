//
//  NotificationTableCell.swift
//  RCRC
//
//  Created by Aashish Singh on 29/08/22.
//

import UIKit

class NotificationTableCell: UITableViewCell {

    @IBOutlet weak var notificationDate: UILabel!
    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var notificationMessageLabel: UILabel!
    @IBOutlet weak var notificationSubMessageLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        configureUIViewas()
    }
    
    private func configureUIViewas() {
        
        notificationDate.setAlignment()
        notificationTitleLabel.setAlignment()
        notificationTitleLabel.font = Fonts.Bold.seventeen
        notificationMessageLabel.setAlignment()
        notificationDate.textColor = Colors.lightFontGray
        
        self.containerView.layer.shadowColor = Colors.black.cgColor
        self.containerView.layer.shadowOpacity = 0.3
        self.containerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.selectionStyle = .none
        
        if notificationSubMessageLabel != nil {
            notificationSubMessageLabel.setAlignment()
        }
    }
    
    private func configureNonReadCardUI() {
        notificationTitleLabel.textColor = Colors.green
        notificationMessageLabel.textColor = Colors.black
        if notificationSubMessageLabel != nil {
            notificationSubMessageLabel.textColor = Colors.green
        }
    }
    
    private func configureReadCardUI() {
        notificationTitleLabel.textColor = Colors.lightFontGray
        notificationMessageLabel.textColor = Colors.lightFontGray
        if notificationSubMessageLabel != nil {
            notificationSubMessageLabel.textColor = Colors.lightFontGray
        }
    }
    
    func configure(notification: NotificationModel, notificationViewModal: NotificationViewModel) {
        switch notification.isMessageRead {
        case true:
            configureReadCardUI()
        default:
            configureNonReadCardUI()
        }
        
        notificationDate.text = notificationViewModal.notificationDateTime(notification: notification)
        notificationTitleLabel.text = notification.title
        notificationMessageLabel.text = notification.message
        notificationSubMessageLabel.text = notification.subMessage
        
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
