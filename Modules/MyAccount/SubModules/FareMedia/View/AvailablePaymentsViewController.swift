//
//  AvailablePaymentsViewController.swift
//  RCRC
//
//  Created by Errol on 03/08/21.
//

import UIKit
import PassKit
import Alamofire

final class AvailablePaymentsViewController: UIViewController {

    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Colors.green
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        return refreshControl
    }()
    @IBOutlet weak var tableView: UITableView!
    private var paymentMethods: PaymentMethods?
    let viewModel = AvailablePaymentsViewModel()
    private var product: FareMediaAvailableProduct!
    var activityIndicator: UIActivityIndicatorView?
    
    var applePayViewModal = ApplePayViewModal()
    let applePayServiceViewModel = ApplePayServiceViewModel()

    convenience init(product: FareMediaAvailableProduct) {
        self.init(nibName: AvailablePaymentsViewController.nibName, bundle: nil)
        self.product = product
    }

    static var nibName: String {
        return String(describing: self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        fetchPaymentMethods()
        self.disableLargeNavigationTitleCollapsing()
    }

    @objc private func onRefresh(_ sender: UIRefreshControl) {
        if sender.isRefreshing {
            fetchPaymentMethods()
        }
    }

    private func configureView() {
        configureNavigationBar(title: Constants.availablePaymentMethods.localized)
        tableView.refreshControl = refreshControl
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.register(TableViewCellWithAccessoryIndicator.self, forCellReuseIdentifier: TableViewCellWithAccessoryIndicator.identifier)
        
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    private func fetchPaymentMethods() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        refreshControl.beginRefreshing()
        viewModel.getPaymentMethods { [weak self] (result) in
            switch result {
            case let .success(paymentMethods):
                self?.paymentMethods = paymentMethods
            case .failure:
                self?.showCustomAlert(alertTitle: Constants.operationFailedTitle,
                                      alertMessage: Constants.operationFailedMessage,
                                      firstActionTitle: ok,
                                      firstActionHandler: {
                                        self?.navigationController?.popViewController(animated: true)
                                      })
            }
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
                self?.tableView.reloadData()
            }
        }
    }
}

extension AvailablePaymentsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = paymentMethods?.items.count ?? 0
        if count > 1 {
            return 1
        }
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: TableViewCellWithAccessoryIndicator = tableView.dequeue(cellForRowAt: indexPath)
        if let paymentMethod = paymentMethods?.items[safe: indexPath.row] {
            cell.configure(text: paymentMethod.name)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        
        /*if let paymentMethod = paymentMethods?.items[safe: indexPath.row],
           let productId = product.code {
            let isFirstClass = product.productCategory == .firstClass
            let viewController = FareMediaPurchaseViewController(productId: productId,
                                                                 isFirstClass: isFirstClass,
                                                                 paymentMethod: paymentMethod.id)
            navigationController?.pushViewController(viewController, animated: true)
        }*/
        if let paymentMethod = paymentMethods?.items[safe: indexPath.row] {
            switch paymentMethod.name.localized == Constants.applePay.localized {
            case true:
                self.performApplePayPay(paymentID: paymentMethod.id)
            case false:
                if let productId = product.code {
                    let isFirstClass = product.productCategory == .firstClass
                    let viewController = FareMediaPurchaseViewController(productId: productId,
                                                                         isFirstClass: isFirstClass,
                                                                         paymentMethod: paymentMethod.id)
                    navigationController?.pushViewController(viewController, animated: true)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.regularTableViewHeaderHeight
    }
    
    func performApplePayPay(paymentID: String) {
        let applePayStatus = applePayViewModal.applePayStatus()
        
        if applePayStatus.canMakePayments {
            applePayViewModal.startPayment(product: product) { appleResponseModal in
                DispatchQueue.main.async {
                    switch appleResponseModal.paymentStatus {
                    case .success:
                        self.activityIndicator = self.startActivityIndicator()
                        self.initiateTRansactionAPI(paymentID: paymentID, appleResponse: appleResponseModal)
                    case .failure:
                        print("**** Apple Payment Failed ****")
                        break
                    default:
                        print("**** Apple Failure Status: \(appleResponseModal.paymentStatus)")
                        break
                    }
                }
            }
            
        } else if applePayStatus.canSetupCards {
            self.setupCards()
        }
        
    }
    
    func initiateTRansactionAPI(paymentID: String, appleResponse: ApplePayModal) {
        let productID = product.code ?? 0
        let isFirstClass = product.productCategory == .firstClass
        
        /*Options :
        let token = appleResponse.token
        let transactionID = appleResponse.transactionIdentifier
        Json value of payment.token.paymentData
         
        In cardDevicePaymentToken field, we need to pass which value from obove options*/
        
        applePayServiceViewModel.initiateTransaction(productId: productID, isFirstClass: isFirstClass, paymentMethod: paymentID, cardDevicePaymentToken: appleResponse.paymentData) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator?.stop()
                switch result {
                case let .success(data):
                    if let transactionId = data.paymentTransactionId {
                       // self?.getTransactionDetailByID(transactionID: transactionId)
                    } else {
                        self?.showOperationFailed()
                    }
                case .failure:
                    self?.showOperationFailed()
                }
            }
        }
    }
   /*
    func getTransactionDetailByID(transactionID: Int) {
        self.activityIndicator = self.startActivityIndicator()
        
        applePayServiceViewModel.getTransactionByID(transactionId: transactionID) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator?.stop()
                switch result {
                case let .success(data):
                     let status = data.status
                        switch status {
                        case "Apple Pay Top Up Error","Apple Pay Paid":
                            self?.reAttemptApplePayTopUp(transactionID: transactionID)
                            break
                        default:
                            self?.showTransactionSuccessful()
                        }
//                     else {
//                        self?.showOperationFailed()
//                    }
                case .failure:
                    self?.showOperationFailed()
                }
            }
        }
    }
   */
    func reAttemptApplePayTopUp(transactionID: Int) {
        self.activityIndicator = self.startActivityIndicator()
        applePayServiceViewModel.reAttemptApplePayTopUp(transactionId: transactionID) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator?.stop()
                switch result {
                case let .success(data):
                    if let status = data.status {
                        switch status {
                        case .applePayError:
                            //Reattemptt API
                            break
                        default:
                            self?.showTransactionSuccessful()
                        }
                    } else {
                        self?.showOperationFailed()
                    }
                case .failure:
                    self?.showOperationFailed()
                }
            }
        }
    }
    
    func showTransactionSuccessful() {
        let viewController: SuccessViewController = SuccessViewController.instantiate(appStoryboard: .reusableSuccess)
        viewController.headerText = Constants.paymentSuccessful.localized
        viewController.descriptionText = Constants.paymentSuccessfulDescription.localized
        viewController.proceedButtonText = done
        viewController.delegate = self
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                self.dismiss(animated: true, completion: {
                    self.navigateToFareMediaScreen()
                })
            }
        }
    }

    func setupCards() {
        let passLibrary = PKPassLibrary()
        passLibrary.openPaymentSetup()
    }
    
    func showOperationFailed() {
        self.showCustomAlert(alertTitle: Constants.transactionCanceled.localized,
                             alertMessage:"",
                              firstActionTitle: ok,
                              firstActionHandler: {
            print("** Dismiss Pressed **")
        })
    }
    
    func navigateToFareMediaScreen() {
        if let viewController = self.navigationController?.viewControllers.first(where: { $0.isKind(of: FareMediaViewController.self) }) {
            self.navigationController?.popToViewController(viewController, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}

extension AvailablePaymentsViewController: SuccessViewDelegate {
    func didTapProceed() {
        navigateToFareMediaScreen()
    }
}

