//
//  SideInfoViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 22/02/23.
//

import UIKit

class SideInfoViewController: UIViewController {

    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var currentActiveNavigationController: UINavigationController?

    private var mainViewController: MainViewController? {
        return self.parent as? MainViewController
    }
    
    @IBOutlet weak var buttonInfoSwip: UIButton!
    var defaultHeight: CGFloat = 0
    var infoViewModel = InfoViewModel()
    var activityIndicator: UIActivityIndicatorView?
    
    var isInfoViewPresenting: Bool = false {
        didSet {
            let infoModel = currentLanguage == .english ? ServiceManager.sharedInstance.infoContentModelEng: ServiceManager.sharedInstance.infoContentModelArabic
            if isInfoViewPresenting && infoModel == nil {
                self.getAboutInfoContentAndGallery(showLoader: true)
            } else {
                if infoModel != nil {
                    self.updateUI(loader: false)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        self.getAboutInfoContentAndGallery()
    }
    
    
    private func getAboutInfoContentAndGallery(showLoader: Bool = false) {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let infoModel = currentLanguage == .english ? ServiceManager.sharedInstance.infoContentModelEng: ServiceManager.sharedInstance.infoContentModelArabic
        
        if showLoader {
            activityIndicator?.stop()
            activityIndicator = startActivityIndicator()
        }
        if infoModel == nil {
            infoViewModel.getInfoContentAPI()
            infoViewModel.infoResult.bind { [weak self] model, error in
                if error != nil || model != nil {
                    if let self = self {
                        if let model = model {
                            if currentLanguage == .english {
                                ServiceManager.sharedInstance.infoContentModelEng = model
                            } else {
                                ServiceManager.sharedInstance.infoContentModelArabic = model
                            }
                            self.updateUI(loader: showLoader)
                        } else {
                            self.dismissUI(loader: showLoader)
                        }
                    }
                }
            }
        } else {
            self.updateUI(loader: showLoader)
        }
    }
    
    private func updateUI(loader: Bool = false) {
        DispatchQueue.main.async {
            if loader { self.activityIndicator?.stop() }
            let content = self.infoViewModel.getInfoTitle()
            self.headerTitle.text = content ?? emptyString
            self.tableView.reloadData()
            
            let indexPath = IndexPath(row: 0, section: 0)
            if let _ = self.tableView.cellForRow(at: indexPath) {
                self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: false)
            }
        }
    }
    
    private func dismissUI(loader: Bool = false) {
        DispatchQueue.main.async {
            if loader { self.activityIndicator?.stop() }
            self.mainViewController?.hideInfoMenu()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func configure() {
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(DescriptionTableViewCell.nib, forCellReuseIdentifier: DescriptionTableViewCell.identifier)
        self.tableView.register(InfoGalleryCell.self)
    }
    
    @IBAction func buttonInfoSwipeTapped(_ sender: UIButton) {
        mainViewController?.hideInfoMenu()
    }
}

extension SideInfoViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return infoViewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: DescriptionTableViewCell? = tableView.dequeueReusableCell(withIdentifier: DescriptionTableViewCell.identifier, for: indexPath) as? DescriptionTableViewCell
        let content = infoViewModel.getInfoContent()
        cell?.configureForAboutBus(content)
        return cell ?? UITableViewCell()
    }
    
}

