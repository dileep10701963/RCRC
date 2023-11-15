//
//  NotificationViewModel.swift
//  RCRC
//
//  Created by Errol on 08/04/21.
//

import Foundation
import UIKit

protocol NotificationSelectionDelegate: AnyObject {
    func didSelectNotification(notification: NotificationModel)
}

class NotificationViewModel: NSObject {

    var notifications: [NotificationModel]?
    weak var delegate: NotificationSelectionDelegate?

    override init() {
        super.init()
        notifications = [
            NotificationModel(title: "TRIP REMINDER", message: "It's time for your schedule trip to 'Club Jawed Frosh'.", date: "24/05/2022", time: "06:30 am", subMessage: "Estimated start time is 06:45 am"),
            NotificationModel(title: "BUS TOPUP", message: "Please top up your monthly bus pass before expiry.", date: "24/05/2022", time: "06:30 am", subMessage: "Expires on 29/05/2022"),
            NotificationModel(title: "BUS 621 DELAY", message: "Bus is delay due to heavy traffic.", date: "24/05/2022", time: "06:30 am", isMessageRead: true),
            NotificationModel(title: "LINE 54 DELAY", message: "Heavy Traffic on Line 54. Please avoid for congestion.", date: "24/05/2022", time: "06:30 am", subMessage: "Estimated time delay is 20 mins"),
            NotificationModel(title: "FALAH PARK EVENT", message: "Book your tickets for the upcoming great falah park show!", date: "24/05/2022", time: "06:30 am", isMessageRead: true)
                        ]
    }
    
    func notificationDateTime(notification: NotificationModel) -> String {
        return "\(notification.date) | \(notification.time)"
    }
    
}

extension NotificationViewModel: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let notifications = notifications {
            return notifications.count
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let notifications = notifications {
            let cell = tableView.dequeueReusableCell(withIdentifier: NotificationTableCell.identifier, for: indexPath) as? NotificationTableCell
            cell?.configure(notification: notifications[indexPath.row], notificationViewModal: self)
            return cell ?? UITableViewCell()
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTableViewCell.identifier, for: indexPath) as? EmptyTableViewCell
            cell?.textLabel?.text = Constants.noNotifications.localized
            cell?.textLabel?.textAlignment = .center
            cell?.textLabel?.font = Fonts.RptaSignage.seventeen
            return cell ?? UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let notifications = notifications {
            delegate?.didSelectNotification(notification: notifications[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            notifications?.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}
