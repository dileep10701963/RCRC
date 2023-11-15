//
//  MyAccountViewController.swift
//  RCRC
//
//  Created by Errol DMello on 13/11/20.
//  Copyright © 2020 Errol DMello. All rights reserved.
//

import UIKit

class MyAccountViewController: ContentViewController {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var myAccountTableView: UITableView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var mobileNumberLabel: UILabel!
    @IBOutlet weak var emailAddressLabel: UILabel!
    @IBOutlet weak var screenLabelName: UILabel!

    var editProfileButton = UIButton()
    let myAccountViewModel = MyAccountViewModel()
    var activityIndicator: UIActivityIndicatorView?
    fileprivate var selectedIndex: Int = -1
    
    var myAccountTableData = [MyAccountModel(image: Images.myAccfareMedia, option: Constants.tickets),
                              MyAccountModel(image: Images.myAccPayMethod, option: Constants.travelPreferences),
                              MyAccountModel(image: Images.myAccfavPlaces, option: Constants.favoritePlaces),
                              MyAccountModel(image: Images.myAccfavPlaces, option: Constants.languageSettings),
                              MyAccountModel(image: Images.myAcclogoout, option: Constants.logOut)]
    
//    MyAccountModel(image: Images.myAcccorrespondence, option: Constants.correspondence),
//    MyAccountModel(image: Images.myAccfavRoutes, option: Constants.favoriteRoutes),
//    MyAccountModel(image: Images.myAccdelete, option: Constants.deleteAccount),

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.configureNavigationBar(title: Constants.myAccount.localized)
        //profileButton.setImage(AppDefaults.shared.isUserLoggedIn ? Images.loggedInUser: Images.hamburgerMenu, for: .normal)
        
        profileButton.setImage(Images.hamburgerMenu, for: .normal)
        fetchProfileDetails()
    }

    private func fetchProfileDetails() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        myAccountViewModel.fetchProfileDetails()
        self.disableUserInteractionWhenAPICalls()
        myAccountViewModel.profileDetailsResult.bind { [weak self] (profile, error) in
            DispatchQueue.main.async {
                if profile != nil || error != nil {
                    self?.enableUserInteractionWhenAPICalls()
                }
                if let self = self {
                    if let profile = profile {
                        self.activityIndicator?.stop()
                        self.setProfileDetails(profileModel: profile)
                    } else if error != nil {
                        self.activityIndicator?.stop()
                        if let error = error as? NetworkError, error == .invalidToken{
                            self.showAlert(for: .invalidToken)
                        } else {
                            self.showAlert(for: .serverError)
                        }
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.logEvent(screen: .myAccount)
        self.profileImage.layer.cornerRadius = self.profileImage.frame.width / 2
        configureTableView()
        self.setProfileDetails(profileModel: nil)
        self.activityIndicator = startActivityIndicator()
        self.screenLabelName.text = Constants.myAccount.localized
        myAccountTableView.backgroundColor = Colors.white
    }
    
    private func setProfileDetails(profileModel: ProfileModel? = nil) {
        if let profileModel = profileModel, profileModel.name?.isEmpty == false  {
            self.nameLabel.text = "\(profileModel.name ?? "")" + " " + "\(profileModel.surname ?? "")" 
            self.mobileNumberLabel.text = profileModel.phone ?? "-----"
            self.emailAddressLabel.text = profileModel.mail ?? "-----"
            self.profileImage.image = Images.profileImagePlaceholder
            self.editProfileButton.isHidden = false
            
            self.mobileNumberLabel.textColor = Colors.rptGreen
            self.emailAddressLabel.textColor = Colors.rptGreen
            
            let subViews = self.navigationController?.navigationBar.subviews
            self.addProfileButtonOnNavigationBar(subViews: subViews)
            
        } else {
            self.nameLabel.text = "-----"
            self.mobileNumberLabel.text = "-----"
            self.emailAddressLabel.text = "-----"
            self.profileImage.image = Images.profileImagePlaceholder
            self.editProfileButton.isHidden = true
        }
    }
    
    func addProfileButtonOnNavigationBar(subViews: [UIView]?) {
        
        let editProfileButton = UIButton(type: .custom)
        editProfileButton.setImage(Images.profileEdit!, for: .normal)
        editProfileButton.contentMode = .scaleAspectFill
        editProfileButton.backgroundColor = .clear
        editProfileButton.tintColor = Colors.rptNavButtonGreen
        editProfileButton.tag = 1040
        editProfileButton.addTarget(self, action: #selector(editProfileTapped(_:)), for: .touchUpInside)
        
        var maxy = self.navigationController?.navigationBar.frame.height ?? 0
        var navWidth = self.navigationController?.navigationBar.frame.width ?? 0
        maxy = maxy - (35 + 4)
        navWidth = navWidth - (35 + 20)
        editProfileButton.frame = CGRect(x: navWidth, y: maxy, width: 35, height: 35)
        
        if let subviews = subViews {
            if subviews.contains(where: {$0.tag == 1040}) {} else {
                self.navigationController?.navigationBar.addSubview(editProfileButton)
            }
        } else {
            self.navigationController?.navigationBar.addSubview(editProfileButton)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let subViews = self.navigationController?.navigationBar.subviews
        if let subviews = subViews {
            for subView in subviews where subView.tag == 1040 {
                subView.removeFromSuperview()
            }
        }
        
    }
    
    @objc func editProfileTapped(_ sender: UIButton) {
        let viewController: EditProfileViewController = EditProfileViewController.instantiate(appStoryboard: .myAccount)
        viewController.editProfileModel = self.myAccountViewModel.profileDetailsResult.value
        self.navigationController?.pushViewController(viewController, animated: true)
    }

    fileprivate func configureTableView() {

        self.myAccountTableView.register(MyAccountNewTableCell.self)
        self.myAccountTableView.dataSource = self
        self.myAccountTableView.delegate = self
        self.myAccountTableView.tableFooterView = UIView()
        self.myAccountTableView.backgroundColor = Colors.backgroundGray
    }

    fileprivate func setUpAttributedString(inputText: String) -> NSMutableAttributedString {
        let twentyTwoFontAttributes = [NSAttributedString.Key.font: Fonts.RptaSignage.twentyTwo, NSMutableAttributedString.Key.foregroundColor: Colors.green]
        let sixteenFontAttributes = [NSMutableAttributedString.Key.font: Fonts.RptaSignage.sixteen, NSMutableAttributedString.Key.foregroundColor: Colors.green]
        var contactType = [String]()
        contactType = inputText.components(separatedBy: " ")
        let contactsplit = contactType.dropFirst()
        let contactRegularText = inputText.components(separatedBy: " ").first ?? emptyString + " ".localized
        let contactRegularString = NSMutableAttributedString(string: contactRegularText, attributes: twentyTwoFontAttributes as [NSAttributedString.Key: Any])
        let contactGreenText = contactsplit.joined(separator: " ").localized
        let contactGreenString = NSMutableAttributedString(string: contactGreenText, attributes: sixteenFontAttributes as [NSAttributedString.Key: Any])
        contactRegularString.append(contactGreenString)
        return contactRegularString
    }
}

extension MyAccountViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myAccountTableData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: MyAccountNewTableCell = tableView.dequeue(cellForRowAt: indexPath)
        cell.configureCell(indexPath: indexPath, data: myAccountTableData, selectedIndex: selectedIndex)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        selectedIndex = indexPath.row
        tableView.reloadData()
        
        switch indexPath.row {
        case 0:
            let fareMediaViewController = FareMediaViewController()
            self.navigationController?.pushViewController(fareMediaViewController, animated: true)
        case 1:
            let allPaymentMethodViewController = ExistingCardsViewController()
            self.navigationController?.pushViewController(allPaymentMethodViewController, animated: true)
        case 2:
            let correspondenceViewController = CorrespondenceViewController.instantiate(appStoryboard: .correspondence)
            self.navigationController?.pushViewController(correspondenceViewController, animated: true)
        case 3:
            let viewController: HomeWorkFavoritesViewController = HomeWorkFavoritesViewController.instantiate(appStoryboard: .homeWorkFavorites)
            viewController.placeType = .favorite
            self.navigationController?.pushViewController(viewController, animated: true)
        case 4:
            let favoriteRoutesViewController: FavoriteRoutesViewController = FavoriteRoutesViewController.instantiate(appStoryboard: .myAccount)
            self.navigationController?.pushViewController(favoriteRoutesViewController, animated: true)
        case 5:
            let deleteAccountViewController = DeleteAccountViewController.instantiate(appStoryboard: .myAccount)
            self.navigationController?.pushViewController(deleteAccountViewController, animated: true)
        case 6:
            showCustomAlert(alertTitle: emptyString,
                            alertMessage: Constants.logoutAlertMessage.localized,
                            firstActionTitle: Constants.logout.localized,
                            secondActionTitle: cancel.localized,
                            secondActionStyle: .cancel,
                            firstActionHandler: performLogout)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

extension MyAccountViewController {
    private func performLogout() {
        if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
            return
        }
        let activity = startActivityIndicator()
        let logoutViewModel = LogoutViewModel()
        logoutViewModel.logout { [weak self] _ in
            activity.stop()
            AppDefaults.shared.isUserLoggedIn = false
//            UserProfileDataRepository.shared.delete()
            UserDefaultService.deleteUserName()
            self?.navigateToDashboard()
        }
    }
}
