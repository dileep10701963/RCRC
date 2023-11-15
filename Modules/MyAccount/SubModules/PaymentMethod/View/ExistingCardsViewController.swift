//
//  ExistingCardsViewController.swift
//  RCRC
//
//  Created by Saheba Juneja on 26/09/22.
//

import UIKit

class ExistingCardsViewController: UIViewController {
    var paymentMethodViewModel = PaymentMethodViewModel()
    @IBOutlet weak var allPaymentMethodsTableView: UITableView!
    @IBOutlet weak var addNewCardButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.configureNavigationBar(title: Constants.addPaymentMethod.localized)
        self.disableLargeNavigationTitleCollapsing()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAllPaymentMethod()
    }
    
    func fetchAllPaymentMethod() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let activityIndicator = startActivityIndicator()
        paymentMethodViewModel.fetchAllPaymentMehthod { responseResult, errr in
            activityIndicator.stop()
            switch errr {
            case .caseIgnore:
                if let items = responseResult.items, items.count > 0 {
                    self.allPaymentMethodsTableView.setEmptyMessageExistingCard("")
                    self.allPaymentMethodsTableView.reloadData()
                } else {
                    self.allPaymentMethodsTableView.setEmptyMessageExistingCard(Constants.noRecordsFound.localized)
                }
            case .invalidData, .invalidURL:
                self.showAlert(for: .serverError)
            case .invalidToken:
                self.showAlert(for: .invalidToken)
            default:
                self.showAlert(for: .serverError)
            }
        }
    }
    
    func setupTableView() {
        self.allPaymentMethodsTableView.register(ExistingCardTableViewCell.nib, forCellReuseIdentifier: ExistingCardTableViewCell.identifier)
        allPaymentMethodsTableView.delegate = paymentMethodViewModel
        allPaymentMethodsTableView.dataSource = paymentMethodViewModel

    }

    
    @IBAction func addNewCard(_ sender: Any) {
        let addPaymentMethodHTMLSessionViewController = AddPaymentMethodHTMLSessionViewController()
        self.navigationController?.pushViewController(addPaymentMethodHTMLSessionViewController, animated: true)
    }
    
}
