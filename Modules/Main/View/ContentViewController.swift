//
//  ContentViewController.swift
//  RCRC
//
//  Created by anand madhav on 10/06/20.
//  Copyright © 2020 anand madhav. All rights reserved.
//

import UIKit

protocol HamburgerMenuDelegate: AnyObject {
    func backTapped()
    func menuTapped()
}

extension HamburgerMenuDelegate {
    func backTapped() {}
    func menuTapped() {}
}

class ContentViewController: UIViewController {

    let profileButton = UIButton(type: .custom)
    let notificationButton = UIButton(type: .custom)
    weak var delegate: HamburgerMenuDelegate?
    let infoButton = UIButton(type: .custom)

    override func viewDidLoad() {
        super.viewDidLoad()

        if let viewControllers = self.navigationController?.viewControllers, viewControllers.contains(where: {$0.isKind(of: AvailableRoutesViewController.self)})  {
            return
        }
    
        //notificationButton.setImage(Images.notification, for: .normal)
        //notificationButton.contentMode = .scaleAspectFit
        //notificationButton.translatesAutoresizingMaskIntoConstraints = false
        //notificationButton.backgroundColor = .clear
        //let notificationBarbutton = UIBarButtonItem(customView: notificationButton)
        
        // Hiding Notification Icon
        //self.navigationItem.rightBarButtonItem = notificationBarbutton
                
        NSLayoutConstraint.activate([
            notificationButton.widthAnchor.constraint(equalToConstant: 35.0),
            notificationButton.heightAnchor.constraint(equalToConstant: 35.0)
        ])

        notificationButton.layer.cornerRadius = 10.0
        notificationButton.clipsToBounds = true
        notificationButton.isHidden = false
        
        /*
        let panGestureRecognizser = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)) )
        view.addGestureRecognizer(panGestureRecognizser)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture(gesture:)))
        swipeRight.direction = .left
        view.addGestureRecognizer(swipeRight)
         */
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let viewControllers = self.navigationController?.viewControllers, viewControllers.contains(where: {$0.isKind(of: AvailableRoutesViewController.self)})  {
            return
        }
        
        self.setNavigationBarAppearance(isPrimaryColorSet: true)
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.backgroundColor = Colors.green
        self.setupHamburgerMenu()
    }
    
    
    private func setupHamburgerMenu() {
//        profileButton.setImage(AppDefaults.shared.isUserLoggedIn ? Images.loggedInUser: Images.hamburgerMenu, for: .normal)
        profileButton.setImage(Images.hamburgerMenu, for: .normal)
        profileButton.contentMode = .scaleAspectFit
        profileButton.backgroundColor = .clear
        notificationButton.setImage(Images.notification, for: .normal)
        notificationButton.contentMode = .scaleAspectFit
        notificationButton.translatesAutoresizingMaskIntoConstraints = false
        notificationButton.backgroundColor = .clear
        profileButton.tag = 1010
        profileButton.addTarget(self, action: #selector(profileButtonTapped(_:)), for: .touchUpInside)
        
        infoButton.setImage(Images.navInfo, for: .normal)
        infoButton.contentMode = .scaleAspectFit
        infoButton.backgroundColor = .clear
        infoButton.tag = 1090
        infoButton.addTarget(self, action: #selector(infoButtonTapped(_:)), for: .touchUpInside)
        
        let logoImageView = UIImageView()
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleToFill
        logoImageView.clipsToBounds = true
        logoImageView.tag = 1030
        logoImageView.image = Images.navigationLogo
        
        var maxy = self.navigationController?.navigationBar.frame.height ?? 0
        //maxy = maxy - (35 + 4)
        maxy = maxy - (65 + 4)
        
        
        let englishX: CGFloat = 20
        let arabicX: CGFloat = UIScreen.main.bounds.width - 55
        
        profileButton.frame = CGRect(x: currentLanguage == .arabic ? arabicX: englishX, y: maxy, width: 35, height: 35)
        
        let englishXForInfo: CGFloat = UIScreen.main.bounds.width - 55
        let arabicXForInfo: CGFloat = 20
        infoButton.frame = CGRect(x: currentLanguage == .arabic ? arabicXForInfo: englishXForInfo, y: maxy, width: 35, height: 35)
        
        let subViews = self.navigationController?.navigationBar.subviews
        
        if let subviews = subViews {
            for subView in subviews where subView.tag == 1020 || subView.tag == 1040 {
                subView.removeFromSuperview()
            }
        }
        
        if let subviews = subViews {
            if subviews.contains(where: {$0.tag == 1010}) {
                for subView in subviews where subView.tag == 1010 {
                    subView.removeFromSuperview()
                }
                self.navigationController?.navigationBar.addSubview(profileButton)

            }
            else {
                self.navigationController?.navigationBar.addSubview(profileButton)
            }
        } else {
            self.navigationController?.navigationBar.addSubview(profileButton)
        }
        
        if let subviews = subViews {
            if subviews.contains(where: {$0.tag == 1090}) {
                for subView in subviews where subView.tag == 1090 {
                    subView.removeFromSuperview()
                }
                self.navigationController?.navigationBar.addSubview(infoButton)

            }
            else {
                self.navigationController?.navigationBar.addSubview(infoButton)
            }
        } else {
            self.navigationController?.navigationBar.addSubview(infoButton)
        }
        
        if let subviews = subViews {
            if subviews.contains(where: {$0.tag == 1030}) {}
            else {
                self.addNavigationViewAndCostraint(imageView: logoImageView)
            }
        } else {
            self.addNavigationViewAndCostraint(imageView: logoImageView)
        }
    }
    
    private func addNavigationViewAndCostraint(imageView: UIImageView) {
        self.navigationController?.navigationBar.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: (self.navigationController?.navigationBar.centerXAnchor)!).isActive = true
        imageView.centerYAnchor.constraint(equalTo: (self.navigationController?.navigationBar.centerYAnchor)!).isActive = true
    }
    

    @IBAction func profileButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if sender.currentImage == Images.backButton {
            delegate?.backTapped()
        } else {
            if AppDefaults.shared.isUserLoggedIn {
                if let mainViewController = self.navigationController?.tabBarController?.parent as? MainViewController {
                    delegate?.menuTapped()
                    mainViewController.toggleSideMenu(fromViewController: self)
                }
            } else {
                let viewController: LoginViewController = LoginViewController.instantiate(appStoryboard: .authentication)
                loginRootView = .myAccount
                viewController.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(viewController, animated: true)
            }
        }
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if let mainViewController = self.navigationController?.tabBarController?.parent as? MainViewController {
            mainViewController.toggleSideInfo(fromViewController: self)
        }
    }

    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        let viewController: InfoViewController = InfoViewController.instantiate(appStoryboard: .settings)
        self.tabBarController?.tabBar.isHidden = true
        viewController.modalPresentationStyle = .overFullScreen
        viewController.delegate = self
        self.presentDetail(viewController)
    }
    
    @objc func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let translation = recognizer.translation(in: self.view)
        guard let mainViewController = self.navigationController?.tabBarController?.parent as? MainViewController else {
            return
        }
        
        if mainViewController.isMenuVisible || translation.x > 0  {
            self.panGestureOfSideMenu(recognizer: recognizer, translation: translation, mainViewController: mainViewController)
        } else {
            self.panGestureOfInfo(recognizer: recognizer, translation: translation, mainViewController: mainViewController)
        }
        
    }
    
    private func panGestureOfSideMenu(recognizer: UIPanGestureRecognizer, translation: CGPoint, mainViewController: MainViewController) {
        
        if recognizer.state == .ended || recognizer.state == .failed || recognizer.state == .cancelled {

            if mainViewController.isMenuVisible {
                // user finger moved to left before ending drag
                if translation.x < 0 {
                    // toggle side menu (to fully hide it)
                    mainViewController.toggleSideMenu(fromViewController: self)
                }
            } else {
                // user finger moved to right and more than 100pt
                if translation.x > 100.0 {
                    // toggle side menu (to fully show it)
                    mainViewController.toggleSideMenu(fromViewController: self)
                } else {
                    // user finger moved to right but too less
                    // hide back the side menu (with animation)
                    mainViewController.view.layoutIfNeeded()
                    UIView.animate(withDuration: 0.3, animations: {
                        mainViewController.sideMenuViewLeadingConstraint.constant = 0 - mainViewController.sideMenuContainer.frame.size.width
                        mainViewController.contentViewLeadingConstraint.constant = 0
                        mainViewController.view.layoutIfNeeded()
                    })
                }
            }
            return
        }

        // if side menu is not visisble
        // and user finger move to right
        // and the distance moved is smaller than the side menu's width
        if !mainViewController.isMenuVisible && translation.x > 0.0 && translation.x <= mainViewController.sideMenuContainer.frame.size.width {
            // move the side menu to the right
            mainViewController.sideMenuViewLeadingConstraint.constant = 0 - mainViewController.sideMenuContainer.frame.size.width + translation.x

            // move the tab bar controller to the right
//            mainViewController.contentViewLeadingConstraint.constant = 0 + translation.x
        }

        // if the side menu is visible
        // and user finger move to left
        // and the distance moved is smaller than the side menu's width
        if mainViewController.isMenuVisible && translation.x < 0.0 && translation.x >= 0 - mainViewController.sideMenuContainer.frame.size.width {
            // move the side menu to the left
            mainViewController.sideMenuViewLeadingConstraint.constant = 0 + translation.x

            // move the tab bar controller to the left
//            mainViewController.contentViewLeadingConstraint.constant = mainViewController.sideMenuContainer.frame.size.width + translation.x
        }
        
    }
    
    private func panGestureOfInfo(recognizer: UIPanGestureRecognizer, translation: CGPoint, mainViewController: MainViewController) {
        
        if recognizer.state == .ended || recognizer.state == .failed || recognizer.state == .cancelled {
            if mainViewController.isInfoVisible {
                if translation.x < 0 {
                    mainViewController.toggleSideInfo(fromViewController: self)
                }
            } else {
                if translation.x < -150.0 {
                    mainViewController.toggleSideInfo(fromViewController: self)
                } else {
                    mainViewController.view.layoutIfNeeded()
                    UIView.animate(withDuration: 0.3, animations: {
                        mainViewController.sideInfoLeadingConstraint.constant = mainViewController.sideMenuContainer.frame.size.width
                        mainViewController.contentViewLeadingConstraint.constant = 0
                        mainViewController.view.layoutIfNeeded()
                    })
                }
            }
            return
        }

        if !mainViewController.isInfoVisible && translation.x < 0.0 && translation.x <= mainViewController.sideInfoContainer.frame.size.width {
            mainViewController.sideInfoLeadingConstraint.constant = UIScreen.main.bounds.size.width + translation.x
        }
        
        if mainViewController.isInfoVisible && translation.x < 0.0 && translation.x >= 0 - mainViewController.sideInfoContainer.frame.size.width {
            mainViewController.sideInfoLeadingConstraint.constant = 0 + translation.x
        }
        
    }
    
}


extension UIViewController {

    func presentDetail(_ viewControllerToPresent: UIViewController) {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromRight
        if let window = self.view.window {
            window.layer.add(transition, forKey: kCATransition)
        }
        present(viewControllerToPresent, animated: false)
    }

    func dismissDetail() {
        let transition = CATransition()
        transition.duration = 0.25
        transition.type = CATransitionType.push
        transition.subtype = CATransitionSubtype.fromLeft
        if let window = self.view.window {
            window.layer.add(transition, forKey: kCATransition)
        }
        dismiss(animated: false)
    }
}


extension ContentViewController: InfoViewDelegate {
    
    func dismissInfoPressed() {
        self.tabBarController?.tabBar.isHidden = false
    }
    
}
