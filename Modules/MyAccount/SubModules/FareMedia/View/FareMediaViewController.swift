//
//  FareMediaViewController.swift
//  RCRC
//
//  Created by anand madhav on 09/03/21.
//

import UIKit
import UserNotifications
import Alamofire
import PassKit

final class FareMediaViewController: ContentViewController {
    
    private var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = Colors.green
        refreshControl.addTarget(self, action: #selector(onRefresh), for: .valueChanged)
        return refreshControl
    }()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    
    private let viewModel = FareMediaViewModel()
    private var fareMedia: (available: [FareMediaAvailableProduct], purchased: [FareMediaPurchasedProduct]) = ([], [])
    let footerView = Component(frame: .zero)
    var isBackButtonPresent: Bool = false
    let userNotificationCenter = UNUserNotificationCenter.current()
    var activityIndicator: UIActivityIndicatorView?
    
    var applePayViewModal = ApplePayViewModal()
    let applePayServiceViewModel = ApplePayServiceViewModel()
    private var product: FareMediaAvailableProduct!
    private var paymentMethods: PaymentMethods?
    private let viewModelAvailablePayment = AvailablePaymentsViewModel()
    //
    @IBOutlet weak var transferentView: UIView!
    @IBOutlet weak var paymentBackView: UIView! 
    @IBOutlet weak var creditBackView: UIView!
    @IBOutlet weak var appleBackView: UIView!
    
    var isApplePaySelected: String!
    
    @IBOutlet weak var applePayButton: UIButton! {
        didSet{
            applePayButton.setImage(UIImage(named:"deselected-green"), for: .normal)
            applePayButton.setImage(UIImage(named:"selected-green"), for: .selected)
        }
    }
    
    @IBOutlet weak var creditCardButton: UIButton! {
        didSet{
            creditCardButton.setImage(UIImage(named:"deselected-green"), for: .normal)
            creditCardButton.setImage(UIImage(named:"selected-green"), for: .selected)
        }
    }
    
    convenience init() {
        self.init(nibName: FareMediaViewController.nibName, bundle: nil)
    }
    
    static var nibName: String {
        return String(describing: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .fareMedia)
        self.transferentView.isHidden = true
        self.paymentBackView.isHidden = true
        configureView()
        requestNotificationAuthorization()
        self.activityIndicator = self.startActivityIndicator()
        activityIndicator?.startAnimating()
        fetchPaymentMethods()
    }
    
    @IBAction func applePayButtonClickAction(_ sender: UIButton) {
        creditCardButton.isSelected = false
        applePayButton.isSelected = true
        isApplePaySelected = "Apple"
        
        UIView.animate(withDuration: 1.0) {
            self.appleBackView.backgroundColor = UIColor(hexString: "F2FDF5")
            self.appleBackView.borderColor = UIColor(hexString: "6FD44F")
            self.creditBackView.borderColor = UIColor(hexString: "F5F5FF")
            self.creditBackView.backgroundColor = UIColor(hexString: "FFFFFF")
        }
    }
    
    @IBAction func closePopUpButtonAction(_ sender: UIButton) {
        UIView.transition(with: self.paymentBackView, duration: 0.5, options: .showHideTransitionViews, animations: {
            self.transferentView.isHidden = true
            self.paymentBackView.isHidden = true
            self.tabBarController?.tabBar.isHidden = false
        })
    }
    
    private func fetchPaymentMethods() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        viewModelAvailablePayment.getPaymentMethods { [weak self] (result) in
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

    @IBAction func continueButtonClickAction(_ sender: UIButton) {
        if isApplePaySelected == "Apple" {
            if let paymentMethod = paymentMethods?.items[0] {
                self.performApplePayPay(paymentID: paymentMethod.id)
            }
        } else if isApplePaySelected == "Credit" {
            guard let paymentMethod = paymentMethods?.items[1] else { return }
            if let productId = product.code {
                let isFirstClass = product.productCategory == .firstClass
                let viewController = FareMediaPurchaseViewController(productId: productId,
                                                                     isFirstClass: isFirstClass,
                                                                     paymentMethod: "creditcard")//paymentMethod.id
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        } else {
            showAlert(title: "", message: "DSSelectPaymentType".localized)
        }
    }
    
    @IBAction func creditCardButtonClickAction(_ sender: UIButton) {
        creditCardButton.isSelected = true
        applePayButton.isSelected = false
        isApplePaySelected = "Credit"
        
        UIView.animate(withDuration: 1.0) {
            self.appleBackView.backgroundColor = UIColor(hexString: "FFFFFF")
            self.creditBackView.borderColor = UIColor(hexString: "6FD44F")
            self.appleBackView.borderColor = UIColor(hexString: "F5F5FF")
            self.creditBackView.backgroundColor = UIColor(hexString: "F2FDF5")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(title: Constants.tickets.localized, showBackButton: isBackButtonPresent)
        fetchFareMedia()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
    }
    
    private func makeNotificationData(product: FareMediaPurchasedProduct) {
        let notificationContent = UNMutableNotificationContent()

        if let validityTime = product.validityTime {
            let ticketType = viewModel.getProductTypeUsingExpirationTIme(expirationTime: validityTime)
            switch ticketType {
            case .twoHour:
                notificationContent.body = Constants.singleTripPassExpire.localized
            case .threeDays:
                notificationContent.body = Constants.threeDaysPassExpire.localized
            case .sevenDays:
                notificationContent.body = Constants.sevenDaysPassExpire.localized
            case .thirtyDays:
                notificationContent.body = Constants.thirtyDaysPassExpire.localized
            case .nDays:
                notificationContent.body = ""
            }
        }
        
        createNotificationDate(notificationContent: notificationContent, product: product)
    }
    
    private func configureView() {
        configureTableView()
    }

    private func createNotificationDate(notificationContent: UNNotificationContent, product: FareMediaPurchasedProduct) {
        let date = product.endDate?.toDate(withFormat: "dd/MM/yyyy hh:mm:ss", timeZone: .AST)
        var notificationDate = Date()
        
        if let validityTime = product.validityTime {
            let ticketType = viewModel.getProductTypeUsingExpirationTIme(expirationTime: validityTime)
            switch ticketType {
            case .twoHour:
                notificationDate = date?.subtracting(mins: -15) ?? Date()
            case .threeDays:
                notificationDate = date?.subtracting(hours: -1) ?? Date()
            case .sevenDays:
                notificationDate = date?.subtracting(days: -1) ?? Date()
            case .thirtyDays:
                notificationDate = date?.subtracting(days: -3) ?? Date()
            case .nDays:
                notificationDate = Date()
            }
        }
        // Create the trigger as a repeating event.
        let trigger = UNCalendarNotificationTrigger(
                 dateMatching: Calendar.current.dateComponents(
                    [.day, .month, .year, .hour, .minute],
                    from: notificationDate), repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: notificationContent, trigger: trigger)

        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.add(request) { (error) in
            print("Request ::", request)
           if error != nil {
              // Handle any errors.
           }
        }
    }
    
    private func configureTableView() {
        tableView.estimatedRowHeight = 43
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = UIView()
        tableView.register(RcrcMyTicketsCell.self)
        tableView.register(RcrcPurchaseNewPassCell.self)
        tableView.registerHeaderFooterViewNib(FareMediaHeaderView.self)
        tableView.separatorStyle = .none
        //footer
        footerView.configure(text: "")
        tableView.tableFooterView = footerView
        tableView.tableFooterView?.backgroundColor = .clear

        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    }

    private func fetchFareMedia() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            //self.tableView.setEmptyMessage(Constants.noRecordsFound.localized)
            if refreshControl.isRefreshing {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
            }
            return
        } else {
            //self.tableView.setEmptyMessage("")
        }
        refreshControl.beginRefreshing()
        viewModel.getPurchasedAndAvailableFareMedia { [weak self] result in
            switch result {
            case let .success(fareMedia):
                self?.footerView.configure(text: "")
                self?.tableView.setEmptyMessage("")

                var enProducts = Array<FareMediaPurchasedProduct>()
                var arProducts = Array<FareMediaPurchasedProduct>()
                var urProducts = Array<FareMediaPurchasedProduct>()
                
                for ap in fareMedia.purchasedProducts {
                    switch currentLanguage {
                    case .english:
                        if ap.locale == "en" && ap.productStatus?.lowercased() != "EXPIRED".lowercased() {
                            enProducts.append(ap)
                        }
                    case .arabic:
                        if ap.locale == "ar" && ap.productStatus?.lowercased() != "EXPIRED".lowercased() {
                            arProducts.append(ap)
                        }
                    case .urdu:
                        if ap.locale == "ur" && ap.productStatus?.lowercased() != "EXPIRED".lowercased() {
                            urProducts.append(ap)
                        }
                    }
                }
                if fareMedia.availableProducts.count == 0 && fareMedia.purchasedProducts.count == 0 {
                    // error
                    self?.handleFareMediaFailure(.invalidData)
                }
                
                if enProducts.count > 0 || arProducts.count > 0 {
                    switch currentLanguage {
                    case .english:
                        self?.fareMedia = ([], enProducts)
                    case .arabic:
                        self?.fareMedia = ([], arProducts)
                    case .urdu:
                        self?.fareMedia = ([], urProducts)
                    }
                } else {
                    switch currentLanguage {
                    case .english:
                        self?.fareMedia = (fareMedia.availableProducts, enProducts)
                    case .arabic:
                        self?.fareMedia = (fareMedia.availableProducts, arProducts)
                    case .urdu:
                        self?.fareMedia = (fareMedia.availableProducts, urProducts)
                    }
                }
                
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
            case let .failure(error):
                self?.handleFareMediaFailure(error)
            }
            DispatchQueue.main.async {
                if let self = self {
                    if self.fareMedia.purchased.isEmpty && self.fareMedia.available.isEmpty {
                        self.footerView.configure(text: "")
                        self.tableView.setEmptyMessage(Constants.noPurchasedTickets.localized)
                    } else {
                        self.footerView.configure(text: Constants.needInternetForTickets.localized)
                    }
                }
                self?.setupTile()
                self?.tableView.reloadData()
            }
        }
    }
    
    private func setupTile() {
        if fareMedia.available.isNotEmpty, fareMedia.purchased.isEmpty {
           titleLabel.text = Constants.purchasedFareMediaTicket.localized
       } else if fareMedia.available.isEmpty, fareMedia.purchased.isNotEmpty {
           titleLabel.text = Constants.purchasedFareMedia.localized
       }
        activityIndicator?.stopAnimating()
    }

    private func fetchFareMediaAfterProductActivation(selectedCell: RcrcMyTicketsCell) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        refreshControl.beginRefreshing()
        viewModel.getPurchasedAndAvailableFareMedia { [weak self] result in
            switch result {
            case let .success(fareMedia):
                self?.footerView.configure(text: "")
                self?.tableView.setEmptyMessage("")

                var enProducts = Array<FareMediaPurchasedProduct>()
                var arProducts = Array<FareMediaPurchasedProduct>()
                var urProducts = Array<FareMediaPurchasedProduct>()
                
                for ap in fareMedia.purchasedProducts {
                    switch currentLanguage {
                    case .english:
                        if ap.locale == "en" && ap.productStatus?.lowercased() != "EXPIRED".lowercased() {
                            self?.makeNotificationData(product: ap)
                            enProducts.append(ap)
                        }
                    case .arabic:
                        if ap.locale == "ar" && ap.productStatus?.lowercased() != "EXPIRED".lowercased() {
                            self?.makeNotificationData(product: ap)
                            arProducts.append(ap)
                        }
                    case .urdu:
                        if ap.locale == "ur" && ap.productStatus?.lowercased() != "EXPIRED".lowercased() {
                            urProducts.append(ap)
                        }
                    }
                }
                
                if enProducts.count > 0 || arProducts.count > 0 {
                    switch currentLanguage {
                    case .english:
                        self?.fareMedia = ([], enProducts)
                    case .arabic:
                        self?.fareMedia = ([], arProducts)
                    case .urdu:
                        self?.fareMedia = ([], urProducts)
                    }
                } else {
                    switch currentLanguage {
                    case .english:
                        self?.fareMedia = (fareMedia.availableProducts, enProducts)
                    case .arabic:
                        self?.fareMedia = (fareMedia.availableProducts, arProducts)
                    case .urdu:
                        self?.fareMedia = (fareMedia.availableProducts, urProducts)
                    }
                }
 
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3)) {
                    self?.refreshControl.endRefreshing()
                    selectedCell.select?()
                }
                
            case let .failure(error):
                self?.handleFareMediaFailure(error)
            }
            DispatchQueue.main.async {
                if let self = self {
                    if self.fareMedia.purchased.isEmpty && self.fareMedia.available.isEmpty {
                        self.footerView.configure(text: "")
                        self.tableView.setEmptyMessage(Constants.noPurchasedTickets.localized)
                    } else {
                        self.footerView.configure(text: Constants.needInternetForTickets.localized)
                    }
                }
                self?.tableView.reloadData()
            }
        }
    }
    
    private func handleFareMediaFailure(_ error: FareMediaError) {
        switch error {
        case .connectivity, .invalidData:
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }

            self.showErrorMessage()
        case .invalidToken, .notLoggedIn:
            self.retryLogin()
        }
        self.fareMedia = ([], [])
    }

    @objc private func onRefresh(_ sender: UIRefreshControl) {
        if sender.isRefreshing {
            self.footerView.configure(text: "")
            tableView.setEmptyMessage("")
            tableView.reloadData()
            fetchFareMedia()
        }
    }

    private func retryLogin() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        AuthenticationService.retryLogin { [weak self] (result) in
            DispatchQueue.main.async {
                self?.refreshControl.endRefreshing()
            }
            switch result {
            case .success:
                self?.fetchFareMedia()
            case .failure:
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing()
                }
                self?.showSessionTimeoutError()
            }
        }
    }

    private func showSessionTimeoutError() {
        DispatchQueue.main.async {
            self.showCustomAlert(alertTitle: emptyString,
                                 alertMessage: Constants.sessionExpiredError.localized,
                                 firstActionTitle: ok,
                                 firstActionHandler: {
                
                DispatchQueue.main.async {
                    AppDefaults.shared.isUserLoggedIn = false
                    UserProfileDataRepository.shared.delete()
                    UserDefaultService.deleteUserName()
                    ServiceManager.sharedInstance.profileModel = nil
                    
                    if let tabBarController = self.tabBarController, let viewControllers = tabBarController.viewControllers, viewControllers.count > 1 {
                        let selectedController = viewControllers[0]
                        self.tabBarController?.selectedViewController = selectedController
                    }
                }
            })
        }
    }
    
    private func showErrorMessage() {
        DispatchQueue.main.async {
            self.showCustomAlert(alertTitle:Constants.serverErrorAlertTitle.localized,
                                 alertMessage: Constants.serverErrorAlertMessage.localized,
                                 firstActionTitle: ok,
                                 firstActionHandler: {
                
                DispatchQueue.main.async {
                    if let tabBarController = self.tabBarController, let viewControllers = tabBarController.viewControllers, viewControllers.count > 1 {
                        let selectedController = viewControllers[0]
                        self.tabBarController?.selectedViewController = selectedController
                    }
                }
            })
        }
    }
}

extension FareMediaViewController: UITableViewDataSource, UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        if fareMedia.available.isNotEmpty, fareMedia.purchased.isNotEmpty {
            return 2
        } else if fareMedia.available.isEmpty, fareMedia.purchased.isEmpty {
            return 0
        }
        return 1
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if fareMedia.available.isNotEmpty, fareMedia.purchased.isNotEmpty {
            return section == 0 ? fareMedia.purchased.count: fareMedia.available.count
        } else if fareMedia.available.isNotEmpty {
            return fareMedia.available.count
        }
        return fareMedia.purchased.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if fareMedia.available.isNotEmpty, fareMedia.purchased.isNotEmpty {
            if indexPath.section == 0 {
                return cellForPurchasedPass(product: fareMedia.purchased[indexPath.row], tableView: tableView, indexPath: indexPath)
            }
            return cellForNewPass(product: fareMedia.available[indexPath.row], tableView: tableView, indexPath: indexPath)
        } else if fareMedia.available.isNotEmpty, fareMedia.purchased.isEmpty {
            return cellForNewPass(product: fareMedia.available[indexPath.row], tableView: tableView, indexPath: indexPath)
        } else if fareMedia.purchased.isNotEmpty, fareMedia.available.isEmpty {
            return cellForPurchasedPass(product: fareMedia.purchased[indexPath.row], tableView: tableView, indexPath: indexPath)
        }
        return .init()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String.className(FareMediaHeaderView.self)) as? FareMediaHeaderView
        if fareMedia.purchased.isEmpty && fareMedia.available.isEmpty {
            return nil
        } else {
            headerView?.configure(available: fareMedia.available, purchased: fareMedia.purchased, section: section)
        }
        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return Constants.headerViewHeight
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let cell = tableView.cellForRow(at: indexPath) as? RcrcPurchaseNewPassCell {
            cell.select?()
        } else if let cell = tableView.cellForRow(at: indexPath) as? RcrcMyTicketsCell {
            let purchasedProduct = fareMedia.purchased[indexPath.row]
            if purchasedProduct.productStatus?.uppercased() == Constants.productExpired {
                showCustomAlert(alertTitle: "", alertMessage: Constants.passExpiredAlertMessage, firstActionTitle: "OK")
            } else if purchasedProduct.productStatus?.uppercased() == Constants.productNeverValidated {
                var alertMessage = ""
                
                if let validityTime = purchasedProduct.validityTime {
                    let ticketType = viewModel.getProductTypeUsingExpirationTIme(expirationTime: validityTime)
                    switch ticketType {
                    case .twoHour:
                        alertMessage = Constants.activatePass
                    case .threeDays:
                        alertMessage = Constants.activate3DaysPass
                    case .sevenDays:
                        alertMessage = Constants.activate7DaysPass
                    case .thirtyDays:
                        alertMessage = Constants.activate30DaysPass
                    case .nDays:
                        alertMessage = ""
                    }
                }
                
                showCustomAlert(alertTitle: Constants.activatePassTitle.localized, alertMessage: alertMessage.localized, firstActionTitle: Constants.buttonYes.localized, firstActionStyle: .default, secondActionTitle: Constants.buttonNo.localized, secondActionStyle: .cancel) {
                    self.handleOKActionToActivateProduct(purchasedProduct: purchasedProduct, cell: cell)
                } secondActionHandler: {}
            }
            else {
                cell.select?()
            }
        }
    }

    private func handleOKActionToActivateProduct(purchasedProduct:FareMediaPurchasedProduct, cell:RcrcMyTicketsCell) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        if let productCode = purchasedProduct.code {
            refreshControl.beginRefreshing()
            viewModel.activateProduct(mediaTypeId: Constants.barcodeType, productId: productCode) { err in
                switch err {
                case .caseIgnore:
                    self.refreshControl.endRefreshing()
                    self.fetchFareMediaAfterProductActivation(selectedCell: cell)
                case .invalidData, .invalidURL:
                    self.refreshControl.endRefreshing()
                    self.footerView.configure(text: "")
                    self.tableView.setEmptyMessage(Constants.noPurchasedTickets.localized)
                case .invalidToken:
                    self.refreshControl.endRefreshing()
                    self.showAlert(for: .invalidToken)
                default:
                    self.refreshControl.endRefreshing()
                    self.footerView.configure(text: "")
                    self.tableView.setEmptyMessage(Constants.noPurchasedTickets.localized)
                }
            }
            
        }
    }
    
    private func cellForNewPass(product: FareMediaAvailableProduct, tableView: UITableView, indexPath: IndexPath) -> RcrcPurchaseNewPassCell {
        let cell: RcrcPurchaseNewPassCell = tableView.dequeue(cellForRowAt: indexPath)
        let cellViewModel = PurchaseNewPassCellViewModel(product: product) { [weak self] in
        if let self = self {
                if let _ = product.code {
                    let isFirstClass = product.productCategory == .firstClass
                    self.product = product
//                    self.hidesBottomBarWhenPushed = true
                    UIView.transition(with: self.paymentBackView, duration: 0.5, options: .transitionCrossDissolve, animations: {
                        self.transferentView.isHidden = false
                        self.paymentBackView.isHidden = false
                        })
                    self.tabBarController?.tabBar.isHidden = true
                }
            }
        }
        cell.configure(viewModel: cellViewModel)
        return cell
    }
    
    func setupCards() {
        let passLibrary = PKPassLibrary()
        passLibrary.openPaymentSetup()
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
        viewController.wantToShowGIF = false
        viewController.modalPresentationStyle = .fullScreen
        self.present(viewController, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(10)) {
                self.dismiss(animated: true, completion: {
                    self.navigateToFareMediaScreen()
                })
            }
        }
    }
    
    func showOperationFailed(_ message: String? = "") {
        guard let _ = message else {
            showAlert(title: Constants.transactionCanceled.localized, message:  Constants.transactionCanceledMessage.localized)
            return
        }
        showAlert(title: Constants.transactionFailed.localized, message:  message ?? Constants.transactionStartFailed)
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

    private func cellForPurchasedPass(product: FareMediaPurchasedProduct, tableView: UITableView, indexPath: IndexPath) -> RcrcMyTicketsCell {
        let cell: RcrcMyTicketsCell = tableView.dequeue(cellForRowAt: indexPath)
        let cellViewModel = PurchasedPassCellViewModel(product: product) { [weak self] in
        }
        cell.passDescription.text = cellViewModel.passName

        if product.productStatus?.uppercased() == Constants.productExpired {
            cell.passDescription.textColor = .lightGray
            cell.passCost.textColor = .lightGray
        } else {
            cell.passDescription.textColor = .black
            cell.passCost.textColor = .black
            let cellViewModel = PurchasedPassCellViewModel(product: product) { [weak self] in
                let viewController = FareMediaBarcodeViewController(product: product)
                self?.navigationController?.pushViewController(viewController, animated: true)
            }
            
            cell.configure(viewModel: cellViewModel)
        }
        return cell
    }
    
    class Component: UIView {

        let label = UILabel(frame: .zero)

        override init(frame: CGRect) {
            super.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 150))
            addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 0
            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 54.0),
                label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16.0),
                label.topAnchor.constraint(equalTo: topAnchor),
                label.bottomAnchor.constraint(equalTo: bottomAnchor),
                ])
        }
        
        func configure(text: String) {
            label.textColor = Colors.rptDarkGreen
            label.font = Fonts.CodecBold.fourteen
            label.text = text
            if !text.isEmpty {
                let ticketInfoString = attributedText(text: Constants.needInternetForTickets.localized, lineSapcing: 4)
                label.attributedText  = ticketInfoString
                label.setAlignment()
            }
            
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

extension FareMediaViewController: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func requestNotificationAuthorization() {
        let authOptions = UNAuthorizationOptions.init(arrayLiteral: .alert, .badge, .sound)
        self.userNotificationCenter.requestAuthorization(options: authOptions) { (success, error) in
            if let error = error {
                print("Error: ", error)
            }
        }
    }
}

extension FareMediaViewController: SuccessViewDelegate {
    func didTapProceed() {
        navigateToFareMediaScreen()
    }
    
    func navigateToFareMediaScreen() {
        if let viewController = self.navigationController?.viewControllers.first(where: { $0.isKind(of: FareMediaViewController.self) }) {
            self.navigationController?.popToViewController(viewController, animated: true)
        } else {
            self.navigationController?.popViewController(animated: true)
        }
    } 
}
