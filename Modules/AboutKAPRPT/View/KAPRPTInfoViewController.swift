//
//  KAPRPTInfoViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 20/12/22.
//

import UIKit

class KAPRPTInfoViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var kaprptInfoViewModel = KAPRPTInfoViewModel()
    var activityIndicator: UIActivityIndicatorView?
    let timeTableButton = UIButton(type: .custom)
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.kaptInfo.localized)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .kaptInfo)
        configureTableView()
        fetchKAPTInfoContent()
        self.disableLargeNavigationTitleCollapsing()
    }
    
    func fetchKAPTInfoContent() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        self.activityIndicator = self.startActivityIndicator()
        var netWorkErrors: [NetworkError] = []
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        kaprptInfoViewModel.getKAPTInfoHeaderImageAPI { responseResult, error in
            switch error {
            case .caseIgnore: break
            case .invalidToken:
                netWorkErrors.append(.invalidToken)
            default:
                netWorkErrors.append(.invalidData)
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        kaprptInfoViewModel.getKAPTInfoContentAPI { responseResult, error in
            switch error {
            case .caseIgnore: break
            case .invalidToken:
                netWorkErrors.append(.invalidToken)
            default:
                netWorkErrors.append(.invalidData)
            }
            dispatchGroup.leave()
        }

        dispatchGroup.enter()
        kaprptInfoViewModel.getKAPTInfoHeaderContentAPI { responseResult, error in
            switch error {
            case .caseIgnore: break
            case .invalidToken:
                netWorkErrors.append(.invalidToken)
            default:
                netWorkErrors.append(.invalidData)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.enter()
        kaprptInfoViewModel.getKAPTInfoURLContentAPI { responseResult, error in
            switch error {
            case .caseIgnore: break
            case .invalidToken:
                netWorkErrors.append(.invalidToken)
            default:
                netWorkErrors.append(.invalidData)
            }
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                self.activityIndicator?.stop()
                
                if netWorkErrors.contains(where: {$0 == .invalidToken}) {
                    self.showAlert(for: .invalidToken)
                } else if netWorkErrors.count > 1 {
                    let errors = netWorkErrors.filter({$0 == .invalidData})
                    if errors.count == 4 {
                        self.tableView.setEmptyMessage(Constants.noRecordsFound.localized)
                    }
                }
                
                self.tableView.reloadData()
            }
        }
        
    }
    
    private func configureTableView() {
        tableView.isHidden = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.register(KAPTInfoHeaderCell.self)
        tableView.register(KAPTInfoContentCell.self)
        tableView.register(KAPTInfoTextCell.self)
        tableView.delegate = kaprptInfoViewModel
        tableView.dataSource = kaprptInfoViewModel
        tableView.backgroundColor = Colors.backgroundGray
    }
    
}
