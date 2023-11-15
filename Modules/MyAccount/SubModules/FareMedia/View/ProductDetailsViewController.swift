//
//  ProductDetailsViewController.swift
//  RCRC
//
//  Created by Ganesh on 30/07/21.
//

import UIKit
import PassKit
import Alamofire

final class ProductDetailsViewController: ContentViewController {
    @IBOutlet weak var productNameLabel: UILabel!
    @IBOutlet weak var productPriceLabel: UILabel!
    @IBOutlet weak var productCodeLabel: UILabel!
    @IBOutlet var arrayImageView: [UIImageView]!
    private var product: FareMediaAvailableProduct!
    private var paymentMethods: PaymentMethods?
    @IBOutlet weak var ticketInfoLabel: UILabel!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    @IBOutlet weak var ticketTypeLabel: UILabel!
    private let viewModel = AvailablePaymentsViewModel()
    @IBOutlet weak var ticketPriceLabel: UILabel!
    @IBOutlet weak var ticketValidityLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var activityIndicator: UIActivityIndicatorView?
    var applePayViewModal = ApplePayViewModal()
    let applePayServiceViewModel = ApplePayServiceViewModel()
    
    convenience init(product: FareMediaAvailableProduct) {
        self.init(nibName: ProductDetailsViewController.nibName, bundle: nil)
        self.product = product
    }
    @IBOutlet weak var leadingSpaceConstraints: NSLayoutConstraint!
    
    static var nibName: String {
        return String(describing: self)
    }

    var productCost: String {
        if let productPrice = product.price {
            let price = (Int(productPrice) / 100)
//            let priceFormat = String(format: "%.2f", price).localized
            return "\(price)\(Constants.currencyTitle.localized)"
        } else {
            return "\(product.price?.string.localized ?? "")\(Constants.currencyTitle.localized)"
        }
    }
    var productValidUntil: String {
        if currentLanguage == .arabic {
            if product.code != nil {
                return Constants.twoHoursValidity
            }
        } else {
            if let productName = product.name {
                switch productName.lowercased() {
                case "Daily".lowercased():
                    return "24 hours"
                case "Single Trip Pass".lowercased(), "Single Pass".lowercased():
                    return "2 Hours"
                case "Monthly".lowercased():
                    return "A month"
                case "7-Day Bus Pass":
                    return "7 days"
                case "3-Day Bus Pass":
                    return "3 days"
                case "30-Day Bus Pass":
                    return "30 days"
                default:
                    return ""
                }
            }
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar(title: Constants.productDetails.localized)
        configureData()
        fetchPaymentMethods()
    }

    private func configureData() {
        switch currentLanguage {
        case .english:
            leadingSpaceConstraints.constant = 50
        case .arabic:
            leadingSpaceConstraints.constant = 90
        default: break
        }
        ticketInfoLabel.setAlignment()
        paymentMethodLabel.setAlignment()
        ticketInfoLabel.attributedText = NSMutableAttributedString(string: Constants.ticketInformation.localized, attributes: [NSAttributedString.Key.font : Fonts.CodecBold.nineteen, .foregroundColor : Colors.black])
        paymentMethodLabel.attributedText = NSMutableAttributedString(string: Constants.paymentMethods.localized, attributes: [NSAttributedString.Key.font : Fonts.CodecBold.nineteen, .foregroundColor : Colors.black])
        for (index, imageView) in arrayImageView.enumerated() {
            arrayImageView[index].image = imageView.image?.setNewImageAsPerLanguage()
        }
        
        ticketTypeLabel.setAlignment()
        ticketPriceLabel.setAlignment()
        ticketValidityLabel.setAlignment()
        ticketTypeLabel.attributedText = NSMutableAttributedString(string: Constants.ticketType.localized, attributes: [NSAttributedString.Key.font : Fonts.CodecBold.sixteen, .foregroundColor : Colors.black])
        ticketPriceLabel.attributedText = NSMutableAttributedString(string: Constants.ticketPrice.localized, attributes: [NSAttributedString.Key.font : Fonts.CodecBold.sixteen, .foregroundColor : Colors.black])
        ticketValidityLabel.attributedText = NSMutableAttributedString(string: Constants.ticketValidity.localized, attributes: [NSAttributedString.Key.font : Fonts.CodecBold.sixteen, .foregroundColor : Colors.black])
        productNameLabel.setAlignment()
        productNameLabel.text = product.name?.localized
        productCodeLabel.setAlignment()
        productCodeLabel.text = productValidUntil.localized
        productPriceLabel.setAlignment()
        productPriceLabel.text = productCost
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        tableView.register(PlacesOfInterestNewCell.self)
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    @IBAction func purchaseTapped(_ sender: UIButton) {
        viewPaymentMethods()
    }

    private func viewPaymentMethods() {
            let viewController = AvailablePaymentsViewController(product: product)
            navigationController?.pushViewController(viewController, animated: true)
    }
    
    private func fetchPaymentMethods() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        viewModel.getPaymentMethods { [weak self] (result) in
            switch result {
            case let .success(paymentMethods):
                self?.paymentMethods = paymentMethods
            case .failure:
                self?.showCustomAlert(alertTitle: Constants.serverErrorAlertTitle.localized,
                                      alertMessage: Constants.serverErrorAlertMessage.localized,
                                      firstActionTitle: ok,
                                      firstActionHandler: {
                                        self?.navigationController?.popViewController(animated: true)
                                      })
            }
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
}

extension ProductDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = paymentMethods?.items.count ?? 0
        /*if count > 1 {
            return 1
        }*/
        return count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: PlacesOfInterestNewCell = tableView.dequeue(cellForRowAt: indexPath)
        if let paymentMethod = paymentMethods?.items[safe: indexPath.row] {
            cell.sectionText.font = Fonts.CodecRegular.sixteen
            cell.configureCell(text: "Pay Via \(paymentMethod.name.capitalized)".localized)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if let paymentMethod = paymentMethods?.items[safe: indexPath.row] {
            switch paymentMethod.name.localized == Constants.applePay.localized {
            case true:
                self.performApplePayPay(paymentID: paymentMethod.id)
            case false:
                if let productId = product.code {
                    let isFirstClass = product.productCategory == .firstClass
                    let viewController = FareMediaPurchaseViewController(productId: productId,
                                                                         isFirstClass: isFirstClass,
                                                                         paymentMethod: paymentMethod.id)//"creditcard"
                    viewController.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(viewController, animated: true)
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
                    case .failure :
                        print("**** Apple Payment Failed **** \(String(describing: appleResponseModal.error))")
                        self.showOperationFailed(appleResponseModal.error?.localizedDescription)
                       // self.showOperationFailed(appleResponseModal.paymentData)
                        break
                    default:
                        print("**** Apple Failure Status: \(appleResponseModal.paymentStatus)")
                        self.showOperationFailed(appleResponseModal.error?.localizedDescription)
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
        let paymentData = appleResponse.paymentData
        
        
        
        applePayServiceViewModel.initiateTransaction(productId: productID, isFirstClass: isFirstClass, paymentMethod: paymentID, cardDevicePaymentToken: paymentData) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator?.stop()
                switch result {
                case let .success(data):
                    if let transactionId = data.paymentTransactionId {
                        /*If everything went well, the APP should not do anything else, the product is paid and top up. However if an error occurs, you should call the service 2.11.3 with the paymentTransactionId that should be returned by the previous service.*/
                        
                        self?.showTransactionSuccessful()
                    } else {
                        self?.showOperationFailed(data.message)
                       // self?.paymentFailureAlert()
                    }
                case .failure:
                    print("failed")
                    self?.showOperationFailed(appleResponse.paymentData)
                    
                   // self?.paymentFailureAlert()
                }
            }
        }
    }
    
    func getTransactionDetailByID(transactionID: Int) {
        self.activityIndicator = self.startActivityIndicator()
        applePayServiceViewModel.getTransactionByID(transactionId: transactionID) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator?.stop()
                switch result {
                case let .success(data):
                    if let status = data.status {
                        switch status {
                        case .applePayError, .applePayPaid:
                            self?.reAttemptApplePayTopUp(transactionID: transactionID)
                        case .applePayDone:
                            self?.showTransactionSuccessful()
                        default:
                            self?.showOperationFailed()
                            //self?.paymentFailureAlert()
                        }
                    } else {
                        self?.showOperationFailed()
                        //self?.paymentFailureAlert()
                        
                    }
                case .failure:
                    self?.showOperationFailed()
                   // self?.paymentFailureAlert()
                }
            }
        }
    }
    
    func reAttemptApplePayTopUp(transactionID: Int) {
        self.activityIndicator = self.startActivityIndicator()
        applePayServiceViewModel.reAttemptApplePayTopUp(transactionId: transactionID) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator?.stop()
                switch result {
                case let .success(data):
                    if let status = data.status {
                        switch status {
                        case .applePayError, .applePayPaid :
                            self?.showOperationFailed()
                        case . applePayDone:
                            self?.showTransactionSuccessful()
                            
                        default:
                            self?.showOperationFailed()
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
    
    func showOperationFailed(_ message: String? = "") {
       
        guard let _ = message else {
            //showScrollableAlert(alertTitle: Constants.transactionCanceled.localized, alertMessage: Constants.transactionCanceledMessage.localized)
            
            showAlert(title: Constants.transactionCanceled.localized, message:  Constants.transactionCanceledMessage.localized)
            
            return
        }
        showAlert(title: Constants.transactionFailed.localized, message:  message ?? Constants.transactionStartFailed)
            //showScrollableAlert(alertTitle: Constants.transactionFailed.localized, alertMessage: message ?? Constants.transactionStartFailed)
        
    }
  
    func navigateToFareMediaScreen() {
        if let viewController = self.navigationController?.viewControllers.first(where: { $0.isKind(of: FareMediaViewController.self) }) {
            self.navigationController?.popToViewController(viewController, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
//    func paymentFailureAlert()  {
//
//        let alert = UIAlertController.init(title: "Transaction failld", message: "Transacion could not complete due some technical reason", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
//
//        self.present(alert, animated: true)
//
//
//    }
    
    func alertMessagePaymentFailledDebugOnly(message:String)  {
        
        let alert = UIAlertController.init(title: "Transaction failld", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        
        self.present(alert, animated: true)
        
        
    }
    
    private func showAlert(title: String, message: String) {
        let alert = AlertDialogController(title: title, message: message)
        let action = AlertAction(title: ok.localized, style: .default)
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true) {
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 6) {
                    self.dismiss(animated: true, completion: {
                        
                    })
                }
            }
        }
    }
    
}

extension ProductDetailsViewController: SuccessViewDelegate {
    func didTapProceed() {
        navigateToFareMediaScreen()
    }
}
