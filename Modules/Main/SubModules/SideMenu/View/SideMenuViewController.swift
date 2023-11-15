//
//  SideMenuViewController.swift
//  RCRC
//
//  Created by anand madhav on 10/06/20.
//  Copyright © 2020 anand madhav. All rights reserved.
//

import UIKit

protocol ProfileViewDelegate: AnyObject {
    func backTapped()
    func loginSuccess()
}

extension ProfileViewDelegate {
    func backTapped() {}
    func loginSuccess() {}
}

enum CellType {
    case purchasehistoryCell
    case travelhistoryCell
    case languageCell
}

class SideMenuViewController: UIViewController {

    @IBOutlet weak var menuTableView: UITableView!
    @IBOutlet weak var versionNumberLabel: UILabel!
    @IBOutlet weak var editProfile: UIButton!
    
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var emailID: UILabel!
    @IBOutlet weak var number: UILabel!
    
    var selectedIndex = -1
    weak var delegate: ProfileViewDelegate?
    var currentActiveNavigationController: UINavigationController?
    private let cellIdentifier = "SideMenuCell"
    let myAccountViewModel = MyAccountViewModel()
    var cellTypeArray: [CellType] = []

    private var mainViewController: MainViewController? {
        return self.parent as? MainViewController
    }

    
    var myAccountTableData = [MyAccountModel(image: Images.myAcccorrespondence, option: Constants.languageSettings.localized),
                              MyAccountModel(image: Images.myAcccTravelHistory, option: Constants.purchaseHistory.localized),
                              MyAccountModel(image: Images.myAccPurchaseHist, option: Constants.travelHistory.localized),
                              MyAccountModel(image: Images.myAccdelete, option: Constants.logOut.localized)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        cellTypeArray.append(.purchasehistoryCell)
        cellTypeArray.append(.travelhistoryCell)
        cellTypeArray.append(.languageCell)
        
        userName.setAlignment()

        if currentLanguage == .english {
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
        } else {
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
        }
        setUpUI()
        self.editProfile.isHidden = true
    }
    
    
    private func fetchProfileDetails() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        myAccountViewModel.fetchProfileDetails()
        myAccountViewModel.profileDetailsResult.bind{ [weak self] (profile, error) in
            DispatchQueue.main.async {
                if profile != nil || error != nil {
                    if self != nil {
                        if let profile = profile {
                            ServiceManager.sharedInstance.profileModel = profile
                            self?.configureUserDetail(model: ServiceManager.sharedInstance.profileModel)
                            self?.menuTableView.reloadData()
                        } else {
                            if let error = error as? NetworkError {
                                if error == .invalidToken || error == .notLoggedIn {
                                    self?.retryLogin()
                                }
                            }
                        }
                    }

                }
            }
        }
    }
    
    private func retryLogin() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        AuthenticationService.retryLogin { [weak self] (result) in
            switch result {
            case .success:
                self?.fetchProfileDetails()
            case .failure:
               break
            }
        }
    }
    
    @IBAction func buttonEditProfileTapped(_ sender: UIButton) {
        if let navigation = currentActiveNavigationController, let lastVC = navigation.viewControllers.last, lastVC.isKind(of: EditProfileViewController.self) {
            mainViewController?.hideSideMenu()
        } else {
            let editProfileController: EditProfileViewController = EditProfileViewController.instantiate(appStoryboard: .myAccount)
            editProfileController.editProfileModel = ServiceManager.sharedInstance.profileModel
            mainViewController?.hideSideMenu()
            editProfileController.hidesBottomBarWhenPushed = true
            currentActiveNavigationController?.pushViewController(editProfileController, animated: true)
        }
    }
    
    func configureTableView() {
        self.menuTableView.register(ListTableViewCell.self)
        self.menuTableView.separatorColor = .lightGray
        self.menuTableView.separatorStyle = .singleLine
        self.menuTableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        self.menuTableView.register(LanguageTableViewCell.self)
        menuTableView.dataSource = self
        menuTableView.delegate = self
        menuTableView.separatorStyle = .none
        menuTableView.alwaysBounceVertical = false
        configureUserDetail(model: ServiceManager.sharedInstance.profileModel)
        
        if #available(iOS 15.0, *) {
            menuTableView.sectionHeaderTopPadding = CGFloat.leastNormalMagnitude
        } else {
            // Fallback on earlier versions
        }
    }
    
    func configureUserDetail(model: ProfileModel?) {
        self.editProfile.isHidden = true
        if let model = ServiceManager.sharedInstance.profileModel, model.name != nil{
            self.editProfile.isHidden = false
        }
        
        if let profileModel = model {
            emailID.text = profileModel.mail
            let formatedNumber = profileModel.phone?.applyPatternOnNumbers(pattern: "+### ### ### ###", replacementCharacter: "#")
            number.text = formatedNumber
            userName.text = "\(profileModel.name ?? emptyString) \(profileModel.surname ?? emptyString)"
        } else {
            emailID.text = "--"
            number.text = "--"
            userName.text = "--"
        }
    }

    override func viewWillLayoutSubviews() {
        // set the bottom constraint value of table view to match the tab bar height
        if let mainViewController = self.parent as? MainViewController,
           mainViewController.childTabBarController != nil {
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        fetchProfileDetails()
        setUpUI()
    }

    func checkedUserLoginOrNot() {
        if AppDefaults.shared.isUserLoggedIn {
            mainViewController?.childTabBarController?.selectedViewController = getViewController(MyAccountViewController.self)
            selectedIndex = -1
        } else {
            let viewController: LoginViewController = LoginViewController.instantiate(appStoryboard: .authentication)
            loginRootView = .myAccount
            viewController.hidesBottomBarWhenPushed = true
            currentActiveNavigationController?.pushViewController(viewController, animated: true)
        }
        self.selectedIndex = -1
        mainViewController?.hideSideMenu()
    }
        private func getViewController(_ kind: AnyClass?) -> UIViewController? {
            guard let kind = kind else { return nil }
            let viewController = mainViewController?.childTabBarController?.viewControllers?.first(where: { viewController in
                viewController.children.contains { $0.isKind(of: kind) }
            })
            return viewController
        }

    @IBAction func hideButtonTapped(_ sender: Any) {
        if self.currentActiveNavigationController != nil,
            let mainViewController = self.parent as? MainViewController {
            self.selectedIndex = -1
            mainViewController.hideSideMenu()
        }
    }
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        self.performLogout()
    }

    func setUpUI() {
        let image = UserProfileDataRepository.shared.fetchImage()
        NotificationCenter.default.addObserver(self, selector: #selector(updateTabbarIndex(_:)), name: NSNotification.Name(rawValue: Constants.updateTabbarIndex), object: nil)
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionNumberLabel.text = "v \(version)"
           }
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        
        if currentLanguage == .english {
            LanguageService.setAppLanguageTo(lang: Languages.arabic.rawValue)
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
            appDelegate?.changeRootViewController(rootViewController, animated: true)
        } else {
            LanguageService.setAppLanguageTo(lang: Languages.english.rawValue)
            UIView.appearance().semanticContentAttribute = .forceLeftToRight
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
            appDelegate?.changeRootViewController(rootViewController, animated: true)
        }
    }
    
    @objc private func updateTabbarIndex(_ notification: NSNotification) {
        if let index = notification.userInfo?[Constants.index] as? Int {
            self.selectedIndex = index
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: Constants.updateTabbarIndex), object: nil)
    }
}

extension SideMenuViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellTypeArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch cellTypeArray[indexPath.row] {
        case .purchasehistoryCell:
            let cell: ListTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
            cell.historyNameLabel.text = "Purchase History".localized
            cell.historyImageView?.image = UIImage(named: "purchase-history")
            return cell
        case .travelhistoryCell:
            let cell: ListTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
            cell.historyNameLabel.text = "Travel History".localized
            cell.historyImageView?.image = UIImage(named: "travel-history")
            return cell
        case .languageCell:
            let cell: LanguageTableViewCell = tableView.dequeue(cellForRowAt: indexPath)
            
            if currentLanguage == .english {
                cell.languageSegmentControl.selectedSegmentIndex = 0
            } else {
                cell.languageSegmentControl.selectedSegmentIndex = 1
            }
            cell.languageSegmentControl.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
            return cell
        }
    }
}

extension SideMenuViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch cellTypeArray[indexPath.row] {
        case .purchasehistoryCell:
            let purchaseHistoryViewController: PurchaseHistoryViewController = PurchaseHistoryViewController(nibName: "PurchaseHistoryViewController", bundle: nil)
            mainViewController?.hideSideMenu()
            purchaseHistoryViewController.hidesBottomBarWhenPushed = true
            currentActiveNavigationController?.pushViewController(purchaseHistoryViewController, animated: true)
     
        case .travelhistoryCell:
            let travelHistoryViewController: TravelHistoryViewController = TravelHistoryViewController(nibName: "TravelHistoryViewController", bundle: nil)
            mainViewController?.hideSideMenu()
            travelHistoryViewController.hidesBottomBarWhenPushed = true
            currentActiveNavigationController?.pushViewController(travelHistoryViewController, animated: true)
       
        case.languageCell:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return UITableView.automaticDimension
        }
}

extension UITableViewCell {
    func addDisclosureIndicator() {
        var disclosureView: UIImageView {
            let imageView = UIImageView(image: Images.profileArrow)
            imageView.frame = CGRect(x: 0, y: 0, width: 15, height: 25)
            imageView.tintColor = Colors.buttonTintColor
            return imageView
        }
        self.accessoryView = disclosureView
    }
}

extension SideMenuViewController {
    
    private func performLogout() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let activity = startActivityIndicator()
        let logoutViewModel = LogoutViewModel()
        logoutViewModel.logout { [weak self] _ in
            activity.stop()
            AppDefaults.shared.isUserLoggedIn = false
            UserProfileDataRepository.shared.delete()
            UserDefaultService.deleteUserName()
            ServiceManager.sharedInstance.profileModel = nil
            self?.navigateToDashboard()
        }
    }
}
