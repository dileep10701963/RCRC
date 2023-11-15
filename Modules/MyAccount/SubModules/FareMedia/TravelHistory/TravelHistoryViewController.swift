//
//  TravelHistoryViewController.swift
//  RCRC
//
//  Created by Saheba Juneja on 03/05/23.
//

import UIKit

class TravelHistoryViewController: ContentViewController {
    
    @IBOutlet weak var travelHistoryTableView: UITableView!
    @IBOutlet weak var fromDateLabel: LocalizedLabel!
    @IBOutlet weak var toDateLabel: LocalizedLabel!
    @IBOutlet weak var fromView: UIView!
    @IBOutlet weak var toView: UIView!
    @IBOutlet weak var noRecordFoundLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var travelHistoryHeaderLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    var fromDate: Date?
    var toDate: Date?
    var travelHistoryViewModel = TravelHistoryViewModel()
    var travelHistorModel = TravelHistory(items: nil)
    var activityIndicator: UIActivityIndicatorView?
    var isDataOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noRecordFoundLabel.translatesAutoresizingMaskIntoConstraints = true
        fromDateLabel.setAlignment()
        toDateLabel.setAlignment()

        registerTableViewCells()
        fetchTravelHistory()
        searchButton.setTitle(Constants.routeTitleSearch.localized, for: .normal)
        
        backButton.setContentHorizontalAlignment()
        let currentDateString = Date().toString(withFormat: Date.dateTimeDOB, timeZone: .AST)//"MM/dd/YYYY"
        self.fromDateLabel.text = Date().subtracting(months: -1)?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)//currentDateString
        self.toDateLabel.text = currentDateString
        self.fromDate = Date().subtracting(months: -1) ?? Date() //self?.fetchMinimumDate()
        //self?.toDate = Date()
        self.setToDate(Date())
        
        let fromViewtap = UITapGestureRecognizer(target: self, action: #selector(self.handleFormViewTappedAction(_:)))
        self.fromView.addGestureRecognizer(fromViewtap)
        self.fromView.isUserInteractionEnabled = true
        
        let toViewtap = UITapGestureRecognizer(target: self, action: #selector(self.handleToViewTappedAction(_:)))
        self.toView.addGestureRecognizer(toViewtap)
        self.toView.isUserInteractionEnabled = true
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.hidesBottomBarWhenPushed = false
    }
    
    func registerTableViewCells() {
        travelHistoryTableView.rowHeight = UITableView.automaticDimension
        travelHistoryTableView.estimatedRowHeight = 44
        travelHistoryTableView.register(TravelHistoryCellTableViewCell.self)
        travelHistoryTableView.delegate = travelHistoryViewModel
        travelHistoryTableView.dataSource = travelHistoryViewModel
        travelHistoryTableView.separatorStyle = .none
    }
    
    func fetchTravelHistory() {
        activityIndicator = self.startActivityIndicator()
        travelHistoryViewModel.getTravelHistory { [weak self] responseModel, errorValue in
            self?.activityIndicator?.stop()
            if let responseModel = responseModel, responseModel.items != nil /*|| error != nil*/ {
                DispatchQueue.main.async {
//                    self?.closeTableHeightConstraint()
                    self?.travelHistoryTableView.reloadData()
                    self?.showHideDateFilter(false)
                    self?.noRecordFoundLabel.text = ""
                }
            } else {
                self?.showHideDateFilter(true)
                self?.noRecordFoundLabel.text = Constants.noRecordsFound.localized
                self?.handleFareMediaFailure(errorValue ?? .invalidData)
            }        }
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
    
    @objc func handleToViewTappedAction(_ sender: UITapGestureRecognizer) {
        
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
    
    @IBAction func backButtonClickActionAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    @IBAction func applyButtonAction(_ sender: Any) {
        let output = TravelHistory(items: self.filterData())
        print("output : \(output)")
        /*self.travelHistoryViewModel.travelHistoryModel = output*/
        self.travelHistoryViewModel.travelHistoryTotalModel = output
        self.travelHistoryViewModel.travelHistoryModel = TravelHistory(items: nil)
        self.travelHistoryViewModel.loadHistoryData()
        self.travelHistoryTableView.reloadData()

        if output.items?.count ?? 0 == 0 {
            self.noRecordFoundLabel.isHidden = false
            self.noRecordFoundLabel.text = Constants.noRecordsFound.localized
        } else {
            self.noRecordFoundLabel.isHidden = true
            self.noRecordFoundLabel.text = ""
        }
    }
    
    func filterData() -> [HistoryItem]? {
        let startdate = self.fromDate
        let enddate = self.toDate
        print("startdate: \(startdate ?? Date())")
        print("enddate: \(enddate ?? Date())")
        print(self.travelHistoryViewModel.searchTravelHistoryModel.items)
        let filteredResult = self.travelHistoryViewModel.searchTravelHistoryModel.items?.filter({$0.recordInDate ?? Date() >= startdate ?? Date() && $0.recordInDate ?? Date() <= enddate ?? Date()})
        return filteredResult
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
        AuthenticationService.retryLogin { [weak self] (result) in
            switch result {
            case .success:
                self?.fetchTravelHistory()
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

    private func fetchMinDateOfMultipleDate(_ selectionDate: Date) -> Date? {
        
        let multipleDates = self.travelHistoryViewModel.searchTravelHistoryModel.items?.filter({($0.recordInDate?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)) == selectionDate.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)})
        print("multipleDates : \(multipleDates)")
        if multipleDates?.count ?? 0 > 0 {
            let multipleDatesMinValue = multipleDates?.min { model1, model2 in
                return model1.recordInDate ?? Date() < model2.recordInDate ?? Date()
            }
            let dateInresponse = multipleDatesMinValue?.date?.toDateLocalEn(timeZone: .AST) ?? Date()
            let formattedDateString = dateInresponse.toString(withFormat: Date.dateTimeHistoryFull, timeZone: .AST)
            print("multipleDatesMinValue String:\(formattedDateString)")
            print("multipleDatesMinValue:\(multipleDatesMinValue?.recordInDate)")
            
            return multipleDatesMinValue?.recordInDate ?? Date()
        } else {
            return nil
        }
    }
    
    private func fetchMaxDateOfMultipleDate(_ selectionDate: Date) -> Date? {
        
        let multipleDates = self.travelHistoryViewModel.searchTravelHistoryModel.items?.filter({($0.recordInDate?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)) == selectionDate.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)})
        print("multipleDates : \(multipleDates)")
        if multipleDates?.count ?? 0 > 0 {
            let multipleDatesMaxValue = multipleDates?.min { model1, model2 in
                return model1.recordInDate ?? Date() > model2.recordInDate ?? Date()
            }
            let dateInresponse = multipleDatesMaxValue?.date?.toDateLocalEn(timeZone: .AST) ?? Date()
            let formattedDateString = dateInresponse.toString(withFormat: Date.dateTimeHistoryFull, timeZone: .AST)
            print("multipleDatesMaxValue String:\(formattedDateString)")
            print("multipleDatesMaxValue:\(multipleDatesMaxValue?.recordInDate)")
            
            return multipleDatesMaxValue?.recordInDate ?? Date()
        } else {
            return nil
        }
    }
    
    private func fetchMinimumDate() -> Date {
        let minimumDate = self.travelHistoryViewModel.searchTravelHistoryModel.items?.min { model1, model2 in
            return model1.recordInDate ?? Date() < model2.recordInDate ?? Date()
        }
        let dateInresponse = minimumDate?.date?.toDateLocalEn(timeZone: .AST) ?? Date()
        let formattedDateString = dateInresponse.toString(withFormat: Date.dateTimeHistoryFull, timeZone: .AST)
        print("minimumDate String:\(formattedDateString)")
        
        print("minimumDate:\(minimumDate?.recordInDate ?? Date())")
        return minimumDate?.recordInDate ?? Date()
    }
    
    private func fetchMaxDateLowestValue() -> Date {
        
        let maxDates = self.travelHistoryViewModel.searchTravelHistoryModel.items?.filter({($0.recordInDate?.toString(withFormat: Date.dateTimeDOB, timeZone: .AST)) == Date().toString(withFormat: Date.dateTimeDOB, timeZone: .AST)})
        print("maxDates : \(maxDates)")
            
        let maxDatesMinValue = maxDates?.min { model1, model2 in
            return model1.recordInDate ?? Date() < model2.recordInDate ?? Date()
        }
        let dateInresponse = maxDatesMinValue?.date?.toDateLocalEn(timeZone: .AST) ?? Date()
        let formattedDateString = dateInresponse.toString(withFormat: Date.dateTimeHistoryFull, timeZone: .AST)
        print("maxDatesMinValue String:\(formattedDateString)")
        print("maxDatesMinValue:\(maxDatesMinValue?.recordInDate)")
        
        return maxDatesMinValue?.recordInDate ?? Date()
    }
}
