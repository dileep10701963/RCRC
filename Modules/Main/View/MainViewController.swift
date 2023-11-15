//
//  MainViewController.swift
//  RCRC
//
//  Created by anand madhav on 10/06/20.
//  Copyright © 2020 anand madhav. All rights reserved.
//

import UIKit

protocol MainViewControllerDelegate: AnyObject {
    func planATripSlideMenuTapped()
    func logoutButtonPressed()
}

extension MainViewControllerDelegate {
    func planATripSlideMenuTapped() {}
    func logoutButtonPressed() {}
}

class MainViewController: UIViewController {

    var isMenuVisible = false
    var isInfoVisible = false
    @IBOutlet weak var sideMenuContainer: UIView!
    @IBOutlet weak var sideInfoContainer: UIView!
    @IBOutlet weak var sideMenuViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var sideInfoLeadingConstraint: NSLayoutConstraint!
    
    var childTabBarController: UITabBarController?
    var sideMenuViewController: SideMenuViewController?
    var sideInfoViewController: SideInfoViewController?
    weak var delegate: MainViewControllerDelegate?
    
    let myAccountViewModel = MyAccountViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // loop through all of the child view controllers (view controllers inside container views)
        // and find the side menu view controller
        for childViewController in self.children {
            if let viewController = childViewController as? SideMenuViewController {
                sideMenuViewController = viewController
            }
            
            if let viewController = childViewController as? SideInfoViewController {
                sideInfoViewController = viewController
            }
            
            if let tabBarViewController = childViewController as? UITabBarController {
                childTabBarController = tabBarViewController
                childTabBarController?.tabBar.isHidden = false
            }
        }
        // hide side menu to the left of screen
        sideMenuViewLeadingConstraint.constant = 0 - UIScreen.main.bounds.width
        sideInfoLeadingConstraint.constant = UIScreen.main.bounds.width
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    @objc func toggleSideMenu(fromViewController: UIViewController) {
        if isMenuVisible {
            UIView.animate(withDuration: 0.3, animations: {
                // hide the side menu to the left
                self.sideMenuViewLeadingConstraint.constant = 0 - self.sideMenuContainer.frame.size.width
                // move the content view (tab bar controller) to original position
                self.contentViewLeadingConstraint.constant = 0
                self.sideMenuViewController?.menuTableView.reloadData()
                self.view.layoutIfNeeded()
            })
        } else {
            
            let viewNavigationController = fromViewController.navigationController
            viewNavigationController?.navigationBar.prefersLargeTitles = true
            viewNavigationController?.navigationItem.largeTitleDisplayMode = .always
            viewNavigationController?.navigationBar.topItem?.title = ""
            viewNavigationController?.navigationItem.hidesBackButton = true
            viewNavigationController?.navigationItem.leftBarButtonItem = nil
            
            self.sideMenuViewController?.currentActiveNavigationController = viewNavigationController
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                // move the side menu to the right to show it
                self.sideMenuViewLeadingConstraint.constant = 0
                self.sideMenuViewController?.menuTableView.reloadData()
                self.view.layoutIfNeeded()
            })
            
            if ServiceManager.sharedInstance.profileModel == nil || ServiceManager.sharedInstance.profileModel?.name == nil || ServiceManager.sharedInstance.profileModel?.name == "" {
                self.fetchProfileDetails()
            }
            
        }
        isMenuVisible = !isMenuVisible
    }
    
    
    @objc func toggleSideInfo(fromViewController: UIViewController) {
        let infoModel = currentLanguage == .english ? ServiceManager.sharedInstance.infoContentModelEng: ServiceManager.sharedInstance.infoContentModelArabic
        
        if infoModel == nil {
            if !Utilities.Connectivity.isConnectedToInternet(viewController: self) {
                return
            }
        }
        if isInfoVisible {
            UIView.animate(withDuration: 0.3, animations: {
                self.sideInfoLeadingConstraint.constant = self.sideInfoContainer.frame.size.width
                self.contentViewLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        } else {
            
            let viewNavigationController = fromViewController.navigationController
            viewNavigationController?.navigationBar.prefersLargeTitles = true
            viewNavigationController?.navigationItem.largeTitleDisplayMode = .always
            viewNavigationController?.navigationBar.topItem?.title = ""
            viewNavigationController?.navigationItem.hidesBackButton = true
            viewNavigationController?.navigationItem.leftBarButtonItem = nil
            
            self.sideInfoViewController?.currentActiveNavigationController = viewNavigationController
            self.sideInfoViewController?.isInfoViewPresenting = true
            self.view.layoutIfNeeded()
            UIView.animate(withDuration: 0.3, animations: {
                // move the side menu to the right to show it
                self.sideInfoLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
        }
        isInfoVisible = !isInfoVisible
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
                            self?.sideMenuViewController?.menuTableView.reloadData()
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

    func hideSideMenu() {
        if isMenuVisible {
            UIView.animate(withDuration: 0.3, animations: {
                self.sideMenuViewLeadingConstraint.constant = 0 - self.sideMenuContainer.frame.size.width
                self.contentViewLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
            isMenuVisible = !isMenuVisible
        }
    }
    
    func hideInfoMenu() {
        if isInfoVisible {
            UIView.animate(withDuration: 0.3, animations: {
                self.sideInfoLeadingConstraint.constant = self.sideMenuContainer.frame.size.width
                self.contentViewLeadingConstraint.constant = 0
                self.view.layoutIfNeeded()
            })
            isInfoVisible = !isInfoVisible
        }
    }
}
