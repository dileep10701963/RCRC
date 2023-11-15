//
//  FareTicketingViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 15/11/22.
//

import UIKit

class FareTicketingViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var fareTicketingViewModal = FareTicketingViewModal()
    var activityIndicator: UIActivityIndicatorView?
    let timeTableButton = UIButton(type: .custom)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.fareAndTicketing.localized)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .fareTicketing)
        configureTableView()
        fetchfareTicketingContent()
        self.disableLargeNavigationTitleCollapsing()
    }
    
    func fetchfareTicketingContent() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        self.activityIndicator = self.startActivityIndicator()
        fareTicketingViewModal.getFareTicketingContent { responseResult, errr in
            DispatchQueue.main.async {
                self.activityIndicator?.stop()
                switch errr {
                case .caseIgnore:
                    if let responseResult = responseResult, let item = responseResult.items, item.count > 0 {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.setEmptyMessage(Constants.noRecordsFound.localized)
                    }
                case .invalidToken:
                    self.showAlert(for: .invalidToken)
                default:
                    self.tableView.setEmptyMessage(Constants.noRecordsFound.localized)
                }
                self.tableView.reloadData()
            }
        }
    }
    
    private func configureTableView() {
        tableView.isHidden = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerHeaderFooterViewNib(BusNetworkHeaderView.self)
        tableView.register(BusTableViewCell.self)
        //tableView.register(BusContentTableCell.self)
        tableView.register(OtherFacilitiesCell.self)
        tableView.delegate = fareTicketingViewModal
        tableView.dataSource = fareTicketingViewModal
    }
    
}
