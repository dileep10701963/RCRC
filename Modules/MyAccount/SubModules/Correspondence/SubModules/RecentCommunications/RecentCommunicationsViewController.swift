//
//  RecentCommunicationsViewController.swift
//  RCRC
//
//  Created by Saheba Juneja on 14/09/22.
//

import UIKit

class RecentCommunicationsViewController: UIViewController {

    @IBOutlet weak var recentCommunicationTableView: UITableView!
    var recentCommunicationViewModel = RecentCommunicationViewModel()
    private var activityIndicator: UIActivityIndicatorView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        fetchRecentCommunication()
        self.disableLargeNavigationTitleCollapsing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.correspondence.localized)
    }

    func fetchRecentCommunication() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        self.activityIndicator = self.startActivityIndicator()
        recentCommunicationViewModel.fetchRecentCommunication { responseResult, errr in
            self.activityIndicator?.stop()
            switch errr {
            case .caseIgnore:
                self.recentCommunicationTableView.reloadData()
                if responseResult.items?.count ?? 0 < 1 {
                    self.recentCommunicationTableView.setEmptyMessage(Constants.noRecordsFound)
                }
            case .invalidData, .invalidURL:
                self.recentCommunicationTableView.setEmptyMessage(Constants.noRecordsFound)
            case .invalidToken:
                self.showAlert(for: .invalidToken)
            default:
                self.recentCommunicationTableView.setEmptyMessage(Constants.noRecordsFound)
                self.showAlert(for: .serverError)
            }
        }
    }
    
    func setupTableView() {
        self.recentCommunicationTableView.register(RecentCommunicationCell.nib, forCellReuseIdentifier: RecentCommunicationCell.identifier)
        recentCommunicationTableView.delegate = recentCommunicationViewModel
        recentCommunicationTableView.dataSource = recentCommunicationViewModel

    }
}
