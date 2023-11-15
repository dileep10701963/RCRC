//
//  InfoViewController.swift
//  RCRC
//
//  Created by Aashish Singh on 20/02/23.
//

import UIKit

protocol InfoViewDelegate: AnyObject {
    func dismissInfoPressed()
}

class InfoViewController: UIViewController {

    @IBOutlet weak var contentTableView: UITableView!
    @IBOutlet weak var dismissView: UIButton!
    @IBOutlet weak var headerTitle: UILabel!
    
    var defaultHeight: CGFloat = 96
    var infoViewModel = InfoViewModel()
    var activityIndicator: UIActivityIndicatorView?
    weak var delegate: InfoViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configure()
        
        if currentLanguage == .english {
            self.getAboutInfoContentAndGallery()
        } else {
            self.getAboutInfoContentAndGalleryArabic()
        }
        
    }
    
    private func getAboutInfoContentAndGallery() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        activityIndicator = startActivityIndicator()
        if ServiceManager.sharedInstance.infoContentModelEng == nil {
            infoViewModel.getInfoContentAPI()
            infoViewModel.infoResult.bind { [weak self] model, error in
                if error != nil || model != nil {
                    if let self = self {
                        if let model = model {
                            ServiceManager.sharedInstance.infoContentModelEng = model
                            self.updateUI()
                        } else {
                            self.dismissViewController()
                        }
                    }
                }
            }
        } else {
            self.updateUI()
        }
    }
    
    private func getAboutInfoContentAndGalleryArabic() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        activityIndicator = startActivityIndicator()
        if ServiceManager.sharedInstance.infoContentModelArabic == nil {
            infoViewModel.getInfoContentAPI()
            infoViewModel.infoResult.bind { [weak self] model, error in
                if error != nil || model != nil {
                    if let self = self {
                        if let model = model {
                            ServiceManager.sharedInstance.infoContentModelArabic = model
                            self.updateUI()
                        } else {
                            self.dismissViewController()
                        }
                    }
                }
            }
        } else {
            self.updateUI()
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.activityIndicator?.stop()
            let content = self.infoViewModel.getInfoTitle()
            self.headerTitle.text = content ?? emptyString
            self.contentTableView.reloadData()
        }
    }
    
    @IBAction func disMissViewTapped(_ sender: UIButton) {
        dismissViewController()
    }
        
    func dismissViewController() {
        delegate?.dismissInfoPressed()
        self.dismissDetail()
    }

    private func configure() {
        contentTableView.delegate = self
        contentTableView.dataSource = self
        self.contentTableView.register(DescriptionTableViewCell.nib, forCellReuseIdentifier: DescriptionTableViewCell.identifier)
        self.contentTableView.register(InfoGalleryCell.self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension InfoViewController: UITableViewDelegate, UITableViewDataSource {
    
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
