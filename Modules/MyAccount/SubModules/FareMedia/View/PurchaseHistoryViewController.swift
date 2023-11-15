//
//  PurchaseHistoryViewController.swift
//  RCRC
//
//  Created by Bhavin Nagaria on 03/05/23.
//

import UIKit

class PurchaseHistoryViewController: ContentViewController {

    @IBOutlet weak var purchaseHistoryTableView: UITableView!
    @IBOutlet weak var fromDateLabel: LocalizedLabel!
    @IBOutlet weak var toDateLabel: LocalizedLabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var toView: UIView!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var tableviewTopConstraints: NSLayoutConstraint!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var purchaseHistoryHeaderLabel: UILabel!
    @IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var moreHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var noRecordFoundLabel: UILabel!
    @IBOutlet weak var clickableView: UIStackView!
    @IBOutlet weak var backButton: UIButton!
    
    var fromDate: Date?
    var toDate: Date?
    private let viewModel = FareMediaViewModel()
    private let purchaseHistoryViewModel = PurchaseHistoryViewModel()
    var activityIndicatorFooter: UIActivityIndicatorView?
    var isDataOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordFoundLabel.translatesAutoresizingMaskIntoConstraints = true
        configureTableView()
        purchaseHistoryHeaderLabel.text = Constants.purchaseHistory.localized
        purchaseHistoryHeaderLabel.setAlignment()
        fromLabel.text = Constants.from.localized//Constants.dateFrom.localized
        toLabel.text = Constants.to.localized//Constants.dateTo.localized
        
        if currentLanguage == .arabic || currentLanguage == .urdu {
            fromLabel.textAlignment = .left
            toLabel.textAlignment = .left
        } else {
            fromLabel.textAlignment = .right
            toLabel.textAlignment = .right
        }
        backButton.setContentHorizontalAlignment()
        fromDateLabel.setAlignment()
        toDateLabel.setAlignment()
        searchButton.setTitle(Constants.routeTitleSearch.localized, for: .normal)
    
       let currentDateString = Date().toString(withFormat: Date.dateTimeDOB, timeZone: .AST)//"MM/dd/YYYY"
       self.fromDateLabel.text = Date().subtracting(months: -1)?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) //self?.fetchMinimumDate().toString(withFormat: Date.dateTimeDOB, timeZone: .AST)//currentDateString
       self.toDateLabel.text = currentDateString
       self.fromDate = Date().subtracting(months: -1) ?? Date()//self?.fetchMinimumDate()
       self.setToDate(Date())
        
        let fromViewtap = UITapGestureRecognizer(target: self, action: #selector(self.handleFormViewTappedAction(_:)))
        self.fromView.addGestureRecognizer(fromViewtap)
        self.fromView.isUserInteractionEnabled = true
        
        let toViewtap = UITapGestureRecognizer(target: self, action: #selector(self.handleToViewTappedAction(_:)))
        self.toView.addGestureRecognizer(toViewtap)
        self.toView.isUserInteractionEnabled = true
        self.navigationController?.isNavigationBarHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchPurchaseHistory()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.hidesBottomBarWhenPushed = false
    }
    
    @IBAction func backButtonClickActionAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @objc func handleToViewTappedAction(_ sender: UITapGestureRecognizer) {
        showDatePicker(startDate: Date().subtracting(months: -1) ?? Date()/*fetchMinimumDate()*/) { selection in
            DispatchQueue.main.async {
                self.setToDate(selection.date)
            }
        }
    }
    
    @objc func handleFormViewTappedAction(_ sender: UITapGestureRecognizer) {
        
        showDatePicker(startDate: Date().subtracting(months: -1) ?? Date()/*fetchMinimumDate()*/) { selections in
            DispatchQueue.main.async {
                
                let minimumDate = self.fetchMinimumDate()
                let maxDateLowestValue = self.fetchMaxDateLowestValue()
                
                if selections.date.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) == minimumDate.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) {
                    let dateValue = selections.date
                    let timeIntval = minimumDate.timeIntervalSince(dateValue)
                    print("timeIntval : \(timeIntval)")
                    let latestDate = selections.date.addingTimeInterval(timeIntval)
                    print("latestD : \(latestDate)")
                    
                    if latestDate == minimumDate {
                        let dateString = latestDate.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) //"MM/dd/YY"
                        self.fromDateLabel.text = dateString
                        print("FdateString: \(dateString)")
                        let fromString = latestDate.toString(timeZone: .AST)
                        print("FdateString1: \(fromString)")
                        let ndate = fromString.toDateLocalEn(timeZone: .AST)
                        self.fromDate = ndate
                        print("ndate : \(ndate ?? Date())")
                    } else {
                        let minDateMultipleDateValue = self.fetchMinDateOfMultipleDate(selections.date)
                        
                        var latestDate: Date?
                        if minDateMultipleDateValue != nil {
                            let dateValue = selections.date
                            let timeIntval = minDateMultipleDateValue?.timeIntervalSince(dateValue)
                            print("timeIntval : \(timeIntval)")
                            latestDate = selections.date.addingTimeInterval(timeIntval ?? 0.0)
                            print("latestD : \(latestDate)")
                        } else {
                            latestDate = selections.date
                        }
                        let dateString = latestDate?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) //"MM/dd/YY"
                        self.fromDateLabel.text = dateString
                        print("FdateString: \(dateString)")
                        let fromString = latestDate?.toString(timeZone: .AST)
                        print("FdateString1: \(fromString)")
                        let ndate = fromString?.toDateLocalEn(timeZone: .AST)
                        self.fromDate = ndate
                        print("ndate : \(ndate ?? Date())")
                    }
                } else if selections.date.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) == maxDateLowestValue.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) {
                    
                    let dateValue = selections.date
                    let timeIntval = maxDateLowestValue.timeIntervalSince(dateValue)
                    print("timeIntval : \(timeIntval)")
                    let latestDate = selections.date.addingTimeInterval(timeIntval)
                    print("latestD : \(latestDate)")
                    
                    if latestDate == maxDateLowestValue {
                        let dateString = latestDate.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) //"MM/dd/YY"
                        self.fromDateLabel.text = dateString
                        print("FdateString: \(dateString)")
                        let fromString = latestDate.toString(timeZone: .AST)
                        print("FdateString1: \(fromString)")
                        let ndate = fromString.toDateLocalEn(timeZone: .AST)
                        self.fromDate = ndate
                        print("ndate : \(ndate ?? Date())")
                    } else {
                        let minDateMultipleDateValue = self.fetchMinDateOfMultipleDate(selections.date)
                        
                        var latestDate: Date?
                        if minDateMultipleDateValue != nil {
                            let dateValue = selections.date
                            let timeIntval = minDateMultipleDateValue?.timeIntervalSince(dateValue)
                            print("timeIntval : \(timeIntval)")
                            latestDate = selections.date.addingTimeInterval(timeIntval ?? 0.0)
                            print("latestD : \(latestDate)")
                        } else {
                            latestDate = selections.date
                        }
                        
                        let dateString = latestDate?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) //"MM/dd/YY"
                        self.fromDateLabel.text = dateString
                        print("FdateString: \(dateString)")
                        let fromString = latestDate?.toString(timeZone: .AST)
                        print("FdateString1: \(fromString)")
                        let ndate = fromString?.toDateLocalEn(timeZone: .AST)
                        self.fromDate = ndate
                        print("ndate : \(ndate ?? Date())")
                    }
                } else {
                    let minDateMultipleDateValue = self.fetchMinDateOfMultipleDate(selections.date)
                    
                    var latestDate: Date?
                    if minDateMultipleDateValue != nil {
                        let dateValue = selections.date
                        let timeIntval = minDateMultipleDateValue?.timeIntervalSince(dateValue)
                        print("timeIntval : \(timeIntval)")
                        latestDate = selections.date.addingTimeInterval(timeIntval ?? 0.0)
                        print("latestD : \(latestDate)")
                    } else {
                        latestDate = selections.date
                    }
                    
                    let dateString = latestDate?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) //"MM/dd/YY"
                    self.fromDateLabel.text = dateString
                    print("FdateString: \(dateString)")
                    let fromString = latestDate?.toString(timeZone: .AST)
                    print("FdateString1: \(fromString)")
                    let ndate = fromString?.toDateLocalEn(timeZone: .AST)
                    self.fromDate = ndate
                    print("ndate : \(ndate ?? Date())")
                }
            }
        }
    }
    
    @IBAction func toDateButtonAction(_ sender: Any) {
        showDatePicker(startDate: Date().subtracting(months: -1) ?? Date()/*fetchMinimumDate()*/) { selection in
            DispatchQueue.main.async {
                self.setToDate(selection.date)
            }
        }
    }
    
    private func setToDate(_ selectionDate: Date) {
        DispatchQueue.main.async {
            
            let maxDateMultipleDateValue = self.fetchMaxDateOfMultipleDate(selectionDate)
            var latestDate: Date?
            if maxDateMultipleDateValue != nil {
                let dateValue = selectionDate
                let timeIntval = maxDateMultipleDateValue?.timeIntervalSince(dateValue)
                print("timeIntval : \(timeIntval)")
                latestDate = selectionDate.addingTimeInterval(timeIntval ?? 0.0)
                print("latestD : \(latestDate)")
            } else {
                latestDate = selectionDate
            }
            
            let dateString = latestDate?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) //"MM/dd/YY"
            self.toDateLabel.text = dateString
            print("tdateString2: \(dateString)")
            let toString = latestDate?.toString(timeZone: .AST)
            print("tdateString2: \(toString)")
            let tondate = toString?.toDateLocalEn(timeZone: .AST)
            self.toDate = tondate
            print("ndate : \(tondate ?? Date())")
            
            /*let dateString = selection.date.toString(withFormat: Date.dateTimeDOB, timeZone: .AST) //"MM/dd/YY"
             self.toDateLabel.text = dateString
             print("tdateString2: \(dateString)")
             let toString = selection.date.toString(timeZone: .AST)
             print("tdateString2: \(toString)")
             let tondate = toString.toDateLocalEn(timeZone: .AST)
             self.toDate = tondate
             print("tondate : \(tondate ?? Date())")*/
        }
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        let output = PurchaseHistoryResponseModel(items: self.filterData())
        print("output : \(output)")
        /*self.purchaseHistoryViewModel.purchaseHistoryModel = output*/
        self.purchaseHistoryViewModel.purchaseHistoryTotalModel = output
        self.purchaseHistoryViewModel.purchaseHistoryModel = PurchaseHistoryResponseModel(items: nil)
        self.purchaseHistoryViewModel.loadPurchaseData()
        print(self.purchaseHistoryViewModel.purchaseHistoryModel)
        print(self.purchaseHistoryViewModel.purchaseHistoryTotalModel)
        if isDataOpen {
            self.openTableHeightConstraint()
        } else {
            self.closeTableHeightConstraint()
        }
        self.purchaseHistoryTableView.reloadData()
        
        if output.items?.count ?? 0 == 0 {
            self.noRecordFoundLabel.isHidden = false
            self.noRecordFoundLabel.text = Constants.noRecordsFound.localized
//            self.purchaseHistoryTableView.setEmptyMessage(Constants.noRecordsFound.localized)
        } else {
            self.noRecordFoundLabel.isHidden = true
            self.noRecordFoundLabel.text = ""
        }
    }
    
    @IBAction func moreAction(_ sender: Any) {
        print("load data")
        self.purchaseHistoryViewModel.loadPurchaseData()
        print(self.purchaseHistoryViewModel.purchaseHistoryModel)
        print(self.purchaseHistoryViewModel.purchaseHistoryTotalModel)
        let count = self.purchaseHistoryViewModel.purchaseHistoryModel.items?.count ?? 0
        if isDataOpen {
            self.openTableHeightConstraint()
        } else {
            self.closeTableHeightConstraint()
        }
        self.purchaseHistoryTableView.reloadData()
    }
    
    private func configureTableView() {
        purchaseHistoryTableView.isHidden = false
        purchaseHistoryTableView.rowHeight = UITableView.automaticDimension
        purchaseHistoryTableView.estimatedRowHeight = 44
        purchaseHistoryTableView.register(PurchaseHistoryTableCell.nib, forCellReuseIdentifier: PurchaseHistoryTableCell.identifier)
        purchaseHistoryTableView.register(DescriptionTableCell.nib, forCellReuseIdentifier: DescriptionTableCell.identifier)
        purchaseHistoryViewModel.delegate = self
        purchaseHistoryTableView.delegate = purchaseHistoryViewModel
        purchaseHistoryTableView.dataSource = purchaseHistoryViewModel
    }
    
    private func fetchPurchaseHistory() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        self.activityIndicatorFooter = startActivityIndicator()
        self.purchaseHistoryViewModel.purchaseHistory { [weak self] responseModel, errorValue in
            self?.activityIndicatorFooter?.stop()
            if let responseModel = responseModel, responseModel.items != nil /*|| error != nil*/ {
               
                DispatchQueue.main.async {
                    self?.closeTableHeightConstraint()
                    self?.purchaseHistoryTableView.reloadData()
                    self?.showHideDateFilter(false)
                    self?.noRecordFoundLabel.text = ""
                }
            } else {
                self?.showHideDateFilter(true)
                self?.noRecordFoundLabel.text = Constants.noRecordsFound.localized
                self?.handleFareMediaFailure(errorValue ?? .invalidData)
            }
        }
    }
    
    private func handleFareMediaFailure(_ error: FareMediaError) {
        switch error {
        case .connectivity, .invalidData:
            self.showErrorMessage()
        case .invalidToken, .notLoggedIn:
            self.retryLogin()
        }
    }

    private func retryLogin() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        self.activityIndicatorFooter = startActivityIndicator()
        AuthenticationService.retryLogin { [weak self] (result) in
            self?.activityIndicatorFooter?.stop()
            switch result {
            case .success:
                self?.fetchPurchaseHistory()
            case .failure:
                self?.showSessionTimeoutError()
            }
        }
    }
    
    private func showSessionTimeoutError() {
        DispatchQueue.main.async {
            self.noRecordFoundLabel.isHidden = false
            self.noRecordFoundLabel.text = Constants.sessionExpiredError.localized
            
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
            
            self.noRecordFoundLabel.isHidden = false
            self.noRecordFoundLabel.text = Constants.noRecordsFound.localized
            /*self.showCustomAlert(alertTitle:Constants.serverErrorAlertTitle.localized,
                                 alertMessage: Constants.serverErrorAlertMessage.localized,
                                 firstActionTitle: ok,
                                 firstActionHandler: {
                
                DispatchQueue.main.async {
                    if let tabBarController = self.tabBarController, let viewControllers = tabBarController.viewControllers, viewControllers.count > 1 {
                        let selectedController = viewControllers[0]
                        self.tabBarController?.selectedViewController = selectedController
                    }
                }
            })*/
        }
    }
    
    private func showHideDateFilter(_ isHide: Bool) {
        noRecordFoundLabel.isHidden = isHide
    }
    
    func filterData() -> [PurchaseHistoryModel]? {
        let startdate = self.fromDate
        let enddate = self.toDate
        print("startdate: \(startdate ?? Date())")
        print("enddate: \(enddate ?? Date())")
        print(self.purchaseHistoryViewModel.searchPurchaseHistoryModel.items)
        let filteredResult = self.purchaseHistoryViewModel.searchPurchaseHistoryModel.items?.filter({$0.recordInDate ?? Date() >= startdate ?? Date() && $0.recordInDate ?? Date() <= enddate ?? Date()})
        
        /*if let items = self.purchaseHistoryModel.items {
         var purchaseHistoryModelItems = [PurchaseHistoryModel]()
         print(self.purchaseHistoryModel.items)
         for modelItem in items {
         let rDate = modelItem.recordDate?.toDate(timeZone: .AST)
         //let nDate = rDate?.toString(timeZone: .AST).getDateStringFromString(fromDateFormat: "yyyy-MM-dd'T'HH:mm:ssZ", toDateFormat: "MM/dd/YY")
         //.toDate(timeZone: .AST)
         let n1Date = rDate?.toString(timeZone: .AST)
         print("n1Date: \(n1Date ?? "")")
         
         if let recordDate = rDate {
         print("recordDate: \(recordDate)")
         print("startdate: \(startdate ?? Date())")
         print("enddate: \(enddate ?? Date())")
         
         if let startdate = startdate, let enddate = enddate {
         if recordDate >= startdate {
         if recordDate <= enddate {
         purchaseHistoryModelItems.append(modelItem)
         }
         }
         }
         }
         }
         return purchaseHistoryModelItems
         }*/
            //return output
        //}
        return filteredResult
        //})
    }
    
    private func fetchMinDateOfMultipleDate(_ selectionDate: Date) -> Date? {
        
        let multipleDates = self.purchaseHistoryViewModel.searchPurchaseHistoryModel.items?.filter({($0.recordInDate?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)) == selectionDate.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)})
        print("multipleDates : \(multipleDates)")
        if multipleDates?.count ?? 0 > 0 {
            let multipleDatesMinValue = multipleDates?.min { model1, model2 in
                return model1.recordInDate ?? Date() < model2.recordInDate ?? Date()
            }
            let dateInresponse = multipleDatesMinValue?.recordDate?.toDateLocalEn(timeZone: .AST) ?? Date()
            let formattedDateString = dateInresponse.toString(withFormat: Date.dateTimeHistoryFull, timeZone: .AST)
            print("multipleDatesMinValue String:\(formattedDateString)")
            print("multipleDatesMinValue:\(multipleDatesMinValue?.recordInDate)")
            
            return multipleDatesMinValue?.recordInDate ?? Date()
        } else {
            return nil
        }
    }
    
    private func fetchMaxDateOfMultipleDate(_ selectionDate: Date) -> Date? {
        
        let multipleDates = self.purchaseHistoryViewModel.searchPurchaseHistoryModel.items?.filter({($0.recordInDate?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)) == selectionDate.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)})
        print("multipleDates : \(multipleDates)")
        if multipleDates?.count ?? 0 > 0 {
            let multipleDatesMaxValue = multipleDates?.min { model1, model2 in
                return model1.recordInDate ?? Date() > model2.recordInDate ?? Date()
            }
            let dateInresponse = multipleDatesMaxValue?.recordDate?.toDateLocalEn(timeZone: .AST) ?? Date()
            let formattedDateString = dateInresponse.toString(withFormat: Date.dateTimeHistoryFull, timeZone: .AST)
            print("multipleDatesMaxValue String:\(formattedDateString)")
            print("multipleDatesMaxValue:\(multipleDatesMaxValue?.recordInDate)")
            
            return multipleDatesMaxValue?.recordInDate ?? Date()
        } else {
            return nil
        }
    }
    
    private func fetchMinimumDate() -> Date {
        let minimumDate = self.purchaseHistoryViewModel.searchPurchaseHistoryModel.items?.min { model1, model2 in
            return model1.recordInDate ?? Date() < model2.recordInDate ?? Date()
        }
        let dateInresponse = minimumDate?.recordDate?.toDateLocalEn(timeZone: .AST) ?? Date()
        let formattedDateString = dateInresponse.toString(withFormat: Date.dateTimeHistoryFull, timeZone: .AST)
        print("minimumDate String:\(formattedDateString)")
        
        print("minimumDate:\(minimumDate?.recordInDate)")
        return minimumDate?.recordInDate ?? Date()
    }
    
    private func fetchMaxDateLowestValue() -> Date {
        
        let maxDates = self.purchaseHistoryViewModel.searchPurchaseHistoryModel.items?.filter({($0.recordInDate?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)) == Date().toString(withFormat: Date.dateTimeDOB, timeZone: .AST)})
        print("maxDates : \(maxDates)")
            
        let maxDatesMinValue = maxDates?.min { model1, model2 in
            return model1.recordInDate ?? Date() < model2.recordInDate ?? Date()
        }
        let dateInresponse = maxDatesMinValue?.recordDate?.toDateLocalEn(timeZone: .AST) ?? Date()
        let formattedDateString = dateInresponse.toString(withFormat: Date.dateTimeHistoryFull, timeZone: .AST)
        print("maxDatesMinValue String:\(formattedDateString)")
        print("maxDatesMinValue:\(maxDatesMinValue?.recordInDate)")
        
        return maxDatesMinValue?.recordInDate ?? Date()
    }
}

extension PurchaseHistoryViewController: PurchaseHistoryDelegate {
    func openTableHeightConstraint() {
        print("Open")
        isDataOpen = true
        //self.tableViewHeightConstraint.constant = 533.0
//        self.tableViewHeightConstraint.constant = CGFloat(((self.purchaseHistoryViewModel.purchaseHistoryModel.items?.count ?? 0) * 59) + 260)

        }
    
    func closeTableHeightConstraint() {
        print("Close")
        isDataOpen = false
        //self.tableViewHeightConstraint.constant = 295.0
//        self.tableViewHeightConstraint.constant = CGFloat((self.purchaseHistoryViewModel.purchaseHistoryModel.items?.count ?? 1) * 59)
        }
    }
