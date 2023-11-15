//
//  NotificationViewController.swift
//  RCRC
//
//  Created by Errol on 08/04/21.
//

import UIKit

class NotificationViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    let notificationViewModel = NotificationViewModel()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.notifications.localized)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .notification)
        configureTableView()
    }

    private func configureTableView() {
        tableView.register(NotificationTableCell.nib, forCellReuseIdentifier: NotificationTableCell.identifier)
        tableView.register(NotificationTableViewCell.nib, forCellReuseIdentifier: NotificationTableViewCell.identifier)
        tableView.register(EmptyTableViewCell.self, forCellReuseIdentifier: EmptyTableViewCell.identifier)
        notificationViewModel.delegate = self
        tableView.dataSource = notificationViewModel
        tableView.delegate = notificationViewModel
        tableView.tableFooterView = UIView()
    }
}

extension NotificationViewController: NotificationSelectionDelegate {
    
    func didSelectNotification(notification: NotificationModel) {
        let notificationDetailViewController: NotificationDetailViewController = NotificationDetailViewController.instantiate(appStoryboard: .notification)
        notificationDetailViewController.notificationDetail = notification
        self.navigationController?.pushViewController(notificationDetailViewController, animated: true)
    }
}
