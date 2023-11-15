//
//  RCRCTabBarController.swift
//  slideMenu
//
//  Created by anand madhav on 09/07/20.
//  Copyright © 2020 fluffy. All rights reserved.
//

import UIKit
import Alamofire

class RCRCTabBarController: UITabBarController, UITabBarControllerDelegate {

    var ticketNavigationController = UINavigationController()
    var homeNavigationController = UINavigationController()
    var faqNavigationController = UINavigationController()
    var routesNavigationController = UINavigationController()
    var previousSelectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.isHidden = false
        setUpTabbar()
        //setAppearance()
        self.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        tabBar.frame = CGRectMake(10, tabBar.frame.origin.y, self.view.frame.width-20, 110)
        tabBar.frame.size.height = 100
//        tabBar.frame.minX = 10
//        tabBar.frame.width = self.view.frame.width-20
        tabBar.frame.origin.y = view.frame.height - 100
        tabBar.uperTwoCornerMask(radius: 30)
        
        if self.selectedIndex == 0 {
            tabBar.backgroundColor = UIColor.white
        } else {
            tabBar.backgroundColor = UIColor.white
        }
        //self.view.backgroundColor = .red
    }
    
    func setAppearance() {
        view.backgroundColor = .red
        self.tabBar.layer.shadowOffset = CGSize(width: 0, height: 0)
        self.tabBar.layer.shadowRadius = 2
        self.tabBar.layer.shadowColor = UIColor.black.cgColor
        self.tabBar.layer.shadowOpacity = 0.3
        
        let normalAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.CodecRegular.twelve, NSAttributedString.Key.foregroundColor: Colors.textColor]
        let selectedAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: Fonts.CodecBold.twelve, NSAttributedString.Key.foregroundColor: Colors.textColor]
        
        if #available(iOS 13.0, *) {
            let tabBarAppearance = UITabBarAppearance()
            let tabBarItemAppearance = UITabBarItemAppearance()
            tabBarItemAppearance.normal.titleTextAttributes = normalAttributes
            tabBarItemAppearance.selected.titleTextAttributes = selectedAttributes
            tabBarAppearance.stackedLayoutAppearance = tabBarItemAppearance
            tabBar.standardAppearance = tabBarAppearance
        } else {
            tabBarItem.setTitleTextAttributes(selectedAttributes, for: .selected)
            tabBarItem.setTitleTextAttributes(selectedAttributes, for: .highlighted)
            tabBarItem.setTitleTextAttributes(normalAttributes, for: .selected)
        }
    }

    func setUpTabbar() {
        
        let controllers: [UINavigationController] = [ controller(for: .planATrip), controller(for: .timeTable), controller(for: .tickets), controller(for: .contact)]
        self.viewControllers = controllers

        let tabBarTitles: [String] = [Constants.tabhome.localized, Constants.timeTable.localized, Constants.buyATicket.localized, Constants.tabContactUs.localized]
        
        let tabBarSelectedImages:[UIImage] = [Images.tabDiscoverSelected!, Images.tabRoutesSelected!, Images.tabTicketSelected!, Images.tabContactSelected!]
        
        let tabBarImages: [UIImage] = [Images.tabHome!, Images.tabTimeTable!, Images.tabTicket!, Images.contactTab!]
        
        if let items = self.tabBar.items {
            for (index, tabBarItem) in items.enumerated(){
               // tabBarItem.title = tabBarTitles[index]
                
                tabBarItem.image = tabBarImages[index]
                let tabBarSelectedImage = tabBarSelectedImages[index]
                tabBarItem.selectedImage = tabBarSelectedImage.withRenderingMode(.alwaysOriginal)
                if tabBarItem == items.first {
                    tabBarItem.imageInsets = UIEdgeInsets.init(top: 15, left: 20, bottom: -15, right:-7)
                }
                else if tabBarItem == items.last {
                    tabBarItem.imageInsets = UIEdgeInsets.init(top: 15, left: -7, bottom: -15, right: 15)
                }
                else{
                    tabBarItem.imageInsets = UIEdgeInsets.init(top: 15, left: 5, bottom: -15, right: 5)
                }
            }
        }
        
    }

    private func controller(for scene: Scenes) -> UINavigationController {
        let viewController: UIViewController
        switch scene {
        case .baseHome:
            viewController = BaseHomeViewController.instantiate(appStoryboard: .home)
            return UINavigationController(rootViewController: viewController)

        case .myAccount:
            viewController = MyAccountViewController.instantiate(appStoryboard: .myAccount)
            return UINavigationController(rootViewController: viewController)

        case .planATrip:
            viewController = HomeViewController.instantiate(appStoryboard: .home)
            homeNavigationController = UINavigationController(rootViewController: viewController)
            return homeNavigationController

        case .contact:
            viewController = FrequentlyAskedQuestionViewController.instantiate(appStoryboard: .frequentlyAskedQuestions)
            faqNavigationController = UINavigationController(rootViewController: viewController)
            return faqNavigationController

        case .news:
            viewController = NewsViewController.instantiate(appStoryboard: .news)
            return UINavigationController(rootViewController: viewController)

        case .settings:
            viewController = SettingsViewController.instantiate(appStoryboard: .settings)
            return UINavigationController(rootViewController: viewController)

        case .timeTable:
            viewController = TimeTableViewController.instantiate(appStoryboard: .busNetwork)
            routesNavigationController = UINavigationController(rootViewController: viewController)
            return routesNavigationController
            
        case .tickets:
           return ticketNavigationController
             
        }
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        print(item)
    /*
        if item == tabBar.items?.first {
            item.imageInsets = UIEdgeInsets.init(top: 10, left: 15, bottom: 0, right: 0)
        }else if item == tabBar.items?.last{
            item.imageInsets = UIEdgeInsets.init(top: 10, left: 0, bottom: 0, right: 15)
        }else{
//        for tabItem in tabBar.isTranslucent {
//            if tabItem == item {
//
//            }
//        }
     */
       
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        print(viewController)
//        if self.selectedIndex == 0 {
//            tabBar.backgroundColor = UIColor.white
//        } else {
//            tabBar.backgroundColor = UIColor.white
//        }
        
        UserDefaultService.setBarcodeView(value: false)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        if UserDefaultService.getBrightness() != "" {
            UIScreen.main.brightness = CGFloat(Float(UserDefaultService.getBrightness()) ?? 0.5)
        }
        
        if let navigationController = viewController as? UINavigationController {
            if navigationController == ticketNavigationController {
                
                print("--------\n",navigationController.viewControllers)
                
                if AppDefaults.shared.isUserLoggedIn {
                    let viewController = FareMediaViewController(nibName: "FareMediaViewController", bundle: nil)
                    if navigationController.viewControllers.count > 1 {
                        if let vc = navigationController.viewControllers.first {
                            if vc.isKind(of: FareMediaViewController.self) {
                                if !AppDefaults.shared.isBarcodeAvailableForOfflinePurpose {
                                    navigationController.popToViewController(vc, animated: false)
                                }
                            } else {
//                                navigationController.setViewControllers([viewController], animated: false)
                            }
                        }
                    } else if navigationController.viewControllers.count == 0 {
                        navigationController.pushViewController(viewController, animated: false)
                    }


                } else {
                    if !AppDefaults.shared.isTicketsVisited {
                        AppDefaults.shared.isTicketsVisited = true
                        showCustomAlert(alertTitle: "", alertMessage: Constants.ticketsVisitedInfo, firstActionTitle: "OK", firstActionStyle: .default) {
                            let viewController = LoginViewController.instantiate(appStoryboard: .authentication)
                            loginRootView = .myAccount
                            viewController.hidesBottomBarWhenPushed = true
                            if let vc = viewController as? LoginViewController {
                                vc.shouldRedirectToTickets = true
                                vc.tabController = self
                                navigationController.pushViewController(vc, animated: false)
                            } else {
                                navigationController.pushViewController(viewController, animated: false)
                            }
                        } secondActionHandler: {}
                    } else {
                        let viewController = LoginViewController.instantiate(appStoryboard: .authentication)
                        loginRootView = .myAccount
                        viewController.hidesBottomBarWhenPushed = true
                        if let vc = viewController as? LoginViewController {
                            vc.shouldRedirectToTickets = true
                            vc.tabController = self
                            navigationController.pushViewController(vc, animated: false)
                        } else {
                            navigationController.pushViewController(viewController, animated: false)
                        }
                    }
                }
            } else {
                if navigationController == homeNavigationController {
                    homeNavigationController.setViewControllers([HomeViewController.instantiate(appStoryboard: .home)], animated: false)
                    print("Selected Index VC ", selectedIndex)
                } else if navigationController == routesNavigationController && previousSelectedIndex != 1 {
                    print("Selected Index VC ", selectedIndex)
                    routesNavigationController.setViewControllers([TimeTableViewController.instantiate(appStoryboard: .busNetwork)], animated: false)
                } else if navigationController == faqNavigationController && previousSelectedIndex != 3 {
                    faqNavigationController.setViewControllers([FrequentlyAskedQuestionViewController.instantiate(appStoryboard: .frequentlyAskedQuestions)], animated: false)
                    print("Selected Index VC ", selectedIndex, navigationController)

                }
            }
        }
     }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool
    {
        previousSelectedIndex = tabBarController.selectedIndex
        print("previousSelectedIndex",tabBarController.selectedIndex)
        if !AppDefaults.shared.isUserLoggedIn {
            switch tabBarController.selectedIndex {
            case 0:
                ticketNavigationController.setViewControllers([HomeViewController.instantiate(appStoryboard: .home)], animated: false)

            case 1:
                ticketNavigationController.setViewControllers([TimeTableViewController.instantiate(appStoryboard: .busNetwork)], animated: false)

            case 3:
                ticketNavigationController.setViewControllers([FrequentlyAskedQuestionViewController.instantiate(appStoryboard: .frequentlyAskedQuestions)], animated: false)

            default:
                ticketNavigationController.setViewControllers([HomeViewController.instantiate(appStoryboard: .home)], animated: false)

            }
        } else {
            if tabBarController.selectedIndex == 2 {
                if ticketNavigationController.viewControllers.count >= 1 {
                    if !AppDefaults.shared.isBarcodeAvailableForOfflinePurpose {
                        if let vc = ticketNavigationController.viewControllers.first {
                            if vc.isKind(of: FareMediaViewController.self) {
                                ticketNavigationController.popToViewController(vc, animated: true)
                            }
                        }
                    }
                }
            }
        }
        return true
    }

    private enum Scenes {
        case baseHome
        case planATrip
        case myAccount
        case contact
        case news
        case settings
        case timeTable
        case tickets
    }
}

