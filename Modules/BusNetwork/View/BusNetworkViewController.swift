//
//  BusNetworkViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 21/10/22.
//

import UIKit

class BusNetworkViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var busNetworkViewModel = BusNetworkViewModel()
    var activityIndicator: UIActivityIndicatorView?
    let timeTableButton = UIButton(type: .custom)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.busTitle.localized)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .busNetwork)
        busNetworkViewModel.delegate = self
        configureTableView()
        fetchBusContent()
        self.disableLargeNavigationTitleCollapsing()
    }
    
    func fetchBusContent() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        self.activityIndicator = self.startActivityIndicator()
        busNetworkViewModel.getBusNetworkContent { responseResult, errr in
            DispatchQueue.main.async {
                self.activityIndicator?.stop()
                switch errr {
                case .caseIgnore:
                    if let responseResult = responseResult, let item = responseResult.items, item.count > 0 {
                        self.tableView.reloadData()
                    } else {
                        self.tableView.setEmptyMessage(Constants.noRecordsFound.localized)
                    }
                    self.tableView.reloadData()
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
        tableView.register(BusDetailsCell.self)
        tableView.register(BusViewTimeTableCell.self)
        tableView.register(OtherFacilitiesCell.self)
        tableView.delegate = busNetworkViewModel
        tableView.dataSource = busNetworkViewModel
    }
}

extension BusNetworkViewController: BusNetworkViewModelDelegate {
    
    func viewTimeTableClicked(cell: UITableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        let fileExtension = self.busNetworkViewModel.busResult?.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].nestedContentFields?[0].contentFieldValue?.document?.fileExtension ?? ""
        
        if fileExtension == emptyString { return }
        switch fileExtension == "pdf" {
        case true:
            let contentPath = self.busNetworkViewModel.busResult?.items?[0].contentFields?[indexPath.section].nestedContentFields?[indexPath.row].nestedContentFields?[0].nestedContentFields?[0].contentFieldValue?.document?.contentURL ?? ""
            let contentURL = URLs.busContentURL + contentPath
            
            if let url = URL(string: contentURL) {
                let viewController: BusNetworkFullViewController = BusNetworkFullViewController.instantiate(appStoryboard: .busNetwork)
                viewController.url = url
                navigationController?.pushViewController(viewController, animated: true)
            }
        case false:
            if let navigationController = self.navigationController {
                let timeTableViewController = TimeTableViewController.instantiate(appStoryboard: .busNetwork)
                navigationController.pushViewController(timeTableViewController, animated: true)
            }
        }
    }
}
