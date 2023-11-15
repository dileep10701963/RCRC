//
//  NotificationDetailViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 30/08/22.
//

import UIKit

class NotificationDetailViewController: UIViewController {

    @IBOutlet weak var notificationDateLabel: UILabel!
    @IBOutlet weak var notificationTitleLabel: UILabel!
    @IBOutlet weak var notificationMessageLabel: UILabel!
    @IBOutlet weak var notificationSubMessageLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    
    var notificationDetail: NotificationModel? 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        self.handleResult(notificationDetail)
    }
    
    private func handleResult(_ result: NotificationModel?) {
        if let data = result {
            notificationTitleLabel.text = data.title
            notificationSubMessageLabel.text = data.subMessage
            notificationMessageLabel.text = data.message
            notificationDateLabel.text = "\(data.date) | \(data.time)"
            if data.subMessage.isEmpty {
                notificationSubMessageLabel.isHidden = true
            }
        }
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.notifications.localized)
    }
    
    func configureUI() {
        notificationDateLabel.setAlignment()
        notificationTitleLabel.setAlignment()
        notificationMessageLabel.setAlignment()
        notificationSubMessageLabel.setAlignment()
        
        notificationTitleLabel.font = Fonts.Bold.seventeen
        notificationDateLabel.textColor = Colors.lightFontGray
        notificationTitleLabel.textColor = Colors.green
        notificationSubMessageLabel.textColor = Colors.green
        notificationMessageLabel.textColor = Colors.black
    }
    
    @IBAction func deleteButtonTapped(_ sender: UIButton) {
    }
    
}
