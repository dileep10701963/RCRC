//
//  TimeTableViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 03/11/22.
//

import UIKit
import Alamofire

class TimeTableViewController: ContentViewController {

    @IBOutlet weak var headeerLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLargeBackground: UIImageView!
    @IBOutlet weak var titleLeftBackground: UIImageView!
    @IBOutlet weak var subHeaderLabel: UILabel!
   // @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonDownloadMap: LoadingButton!
    
    var timeTableViewModel = TimeTableViewModel()
    var viewModel = BaseHomeViewModel()
    
    var activityIndicator: UIActivityIndicatorView?
    var isBackButtonPresent: Bool = false
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar(title: Constants.busTimetable.localized, showBackButton: isBackButtonPresent)
        self.getRouteTitle()
        self.configure()
    }
    
    private func getRouteDetails() {
        if currentLanguage == .arabic {
            if ServiceManager.sharedInstance.routeModelArabic != nil {
                self.activityIndicator?.stop()
                self.tableView.reloadData()
                if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
                    return
                }
            } else {
                self.fetchBusTimeTableContent()
            }
        } else {
            if ServiceManager.sharedInstance.routeModelEng != nil {
                self.activityIndicator?.stop()
                self.tableView.reloadData()
                if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
                    return
                }
            } else {
                self.fetchBusTimeTableContent()
            }
        }
    }
    
    @IBAction func downloadMapTapped(_ sender: UIButton) {
        self.getMapData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        AF.session.getTasksWithCompletionHandler { dataTask, uploadTask, downloadTask in
            downloadTask.forEach({$0.cancel()})
        }
    }
    
    private func getMapData() {
        self.setupDownloadMapButton(showLoader: true)
        viewModel.getHomeMap { [weak self] baseHomeModel, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if baseHomeModel != nil, baseHomeModel?.items?.count ?? 0 > 0 {
                    if let urlIs = URL(string: self.viewModel.getMapPDFURL() ?? emptyString) {
                        AF.download(urlIs).responseData { response in
                            if let data = response.value {
                                let openFile = self.viewModel.openPdfFile()
                                if let fileMURL = openFile.fileManagerURL, let dataOfDir = try? Data(contentsOf: fileMURL) {
                                    if dataOfDir != data {
                                        self.viewModel.saveDownloadedPDFFile(pdfData: data)
                                    } else {
                                       // PDF Data Matched
                                    }
                                } else {
                                    self.viewModel.saveDownloadedPDFFile(pdfData: data)
                                }
                                self.setupDownloadMapButton(showLoader: false)
                                self.showActivityItem()
                            } else {
                                self.setupDownloadMapButton(showLoader: false)
                            }
                        }
                    }
                } else {
                    self.setupDownloadMapButton(showLoader: false)
                }
            }
        }
        
    }
    
    func showActivityItem() {
        let newOpenFile = self.viewModel.openPdfFile()
        if let fileMURL = newOpenFile.fileManagerURL {
            
            let viewController: BusNetworkFullViewController = BusNetworkFullViewController.instantiate(appStoryboard: .busNetwork)
            viewController.isStaticMapLoading = true
            viewController.url = fileMURL
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    private func getRouteTitle() {
        self.buttonDownloadMap.isHidden = true
        
        if currentLanguage == .arabic {
            if ServiceManager.sharedInstance.routeModelTitleArabic != nil {
                let titleContent = self.timeTableViewModel.getBusitleAndHeading()
                self.headeerLabel.attributedText = titleContent.0
                self.headeerLabel.setAlignment()
                
                self.subHeaderLabel.attributedText = titleContent.1
                self.subHeaderLabel.setAlignment()
                //self.bottomConstraint.constant = 12
                self.getRouteDetails()
                self.buttonDownloadMap.isHidden = false
            } else {
                self.fetchBusTimeTableHeaderTitle()
            }
        } else {
            if ServiceManager.sharedInstance.routeModelTitleEng != nil {
                let titleContent = self.timeTableViewModel.getBusitleAndHeading()
                self.headeerLabel.attributedText = titleContent.0
                self.headeerLabel.setAlignment()
                
                self.subHeaderLabel.attributedText = titleContent.1
                self.subHeaderLabel.setAlignment()
               // self.bottomConstraint.constant = 12
                self.getRouteDetails()
                self.buttonDownloadMap.isHidden = false
            } else {
                self.fetchBusTimeTableHeaderTitle()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .busNetwork)
        configureTableView()
        self.disableLargeNavigationTitleCollapsing()
        self.subHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
       // self.bottomConstraint.constant = 0
        
        if #available(iOS 15.0, *) {
            self.tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
    }
    
    private func configure() {
        self.titleLeftBackground.image = self.titleLeftBackground.image?.setNewImageAsPerLanguage()
        self.titleLargeBackground.image = self.titleLargeBackground.image?.setNewImageAsPerLanguage()
        
        self.buttonDownloadMap.titleLabel?.font = Fonts.CodecBold.fourteen
        self.buttonDownloadMap.setTitleColor(Colors.textColor, for: .normal)
        self.setupDownloadMapButton(showLoader: false)
        self.buttonDownloadMap.setTitle(Constants.downloadMap.localized, for: .normal)
    }
    
    func setupDownloadMapButton(showLoader: Bool = false) {
        if showLoader {
            self.buttonDownloadMap.setImage(nil, for: .normal)
            self.buttonDownloadMap.showLoading()
        } else {
            self.buttonDownloadMap.setImage(Images.downloadMap, for: .normal)
            self.buttonDownloadMap.hideLoading()
        }
    }
    
    func fetchBusTimeTableContent() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            self.tableView.setEmptyMessage(Constants.noRecordsFound.localized)
            return
        } else {
            self.tableView.setEmptyMessage("")
        }
        timeTableViewModel.getBusTimeTableContent { [weak self] responseResult, errr in
            self?.activityIndicator?.stop()
            switch errr {
            case .caseIgnore:
                if let responseResult = responseResult, let item = responseResult.items, item.count > 0 {
                    self?.tableView.setEmptyMessage(emptyString)
                    self?.tableView.reloadData()
                } else {
                    self?.tableView.setEmptyMessage(Constants.noRecordsFound.localized)
                }
                self?.tableView.reloadData()
            case .invalidData, .invalidURL:
                self?.tableView.setEmptyMessage(Constants.noRecordsFound.localized)
            case .invalidToken:
                self?.showAlert(for: .invalidToken)
            default:
                self?.tableView.setEmptyMessage(Constants.noRecordsFound.localized)
            }
        }
    }
    
    func fetchBusTimeTableHeaderTitle() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        
        self.activityIndicator = self.startActivityIndicator()
        timeTableViewModel.getBusTimeTableHeaderTitle { [weak self] responseResult, errr in
            if let self = self {
                if let responseResult = responseResult, let item = responseResult.items, item.count > 0 {
                    let titleContent = self.timeTableViewModel.getBusitleAndHeading()
                    self.headeerLabel.attributedText = titleContent.0
                    self.headeerLabel.setAlignment()
                    
                    self.subHeaderLabel.attributedText = titleContent.1
                    self.subHeaderLabel.setAlignment()
                   // self.bottomConstraint.constant = 12
                    self.buttonDownloadMap.isHidden = false
                }
                self.getRouteDetails()
            }
        }
    }
    
    private func configureTableView() {
        tableView.isHidden = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        tableView.registerHeaderFooterViewNib(BusTimeTableHeaderView.self)
        tableView.register(TimeTableContentCell.self)
        //tableView.register(BusTableViewCell.self)
        tableView.register(TimeTablePlaceOfInterestCell.self)
        tableView.register(BusRouteNorthSouthTableViewCell.self)
        tableView.delegate = timeTableViewModel
        tableView.dataSource = timeTableViewModel
        //tableView.backgroundColor = Colors.tableViewHeader
        tableView.sectionFooterHeight = 0
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        self.tableView.contentInsetAdjustmentBehavior = .never
//        if (@available(iOS 11.0, *))
//        {
//            self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
//        }
//        else
//        {
//            self.automaticallyAdjustsScrollViewInsets = NO;
//        }
        
    }
    
}
