//
//  AppDelegate.swift
//  RCRC
//
//  Created by anand madhav on 22/06/20.
//  Copyright © 2020 fluffy. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import Alamofire
import IOSSecuritySuite
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mpTimer: Timer = Timer()
    var secondsElapsed: Double = 0
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if IOSSecuritySuite.amIJailbroken() {
            exit(0)
        } else {
            AppDefaults.shared.isAppLaunched = true
            AppDefaults.shared.isMapAPICalled = true
            AppDefaults.shared.isAppVersionChecked = true
            
            initializeApp()
            UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            
            if #available(iOS 13.0, *) {
                self.window?.overrideUserInterfaceStyle = .light
            }
        }
        
        UserDefaultService.setBrightness(value: "\(UIScreen.main.brightness)")
        
        return true
    }

    func changeRootViewController(_ vc: UIViewController, animated: Bool = true) {
        guard let window = self.window else { return }
        window.rootViewController?.navigationController?.navigationBar.barTintColor = Colors.white
        window.rootViewController?.navigationController?.navigationBar.backgroundColor = Colors.white
        window.rootViewController = vc
        UIView.transition(with: window,
                              duration: 0.5,
                              options: [.transitionCrossDissolve],
                              animations: nil,
                              completion: nil)
    }

    private func initializeApp() {
        saveKeysToKeychain()
        ServiceManager.sharedInstance.fetchWso2Token {success in
            // no need to do anything here
            print("TOken success--->", success)
        }
        configureAppLanguage()
        configureRootViewController()
        Localizer.swizzle()
//        FirebaseApp.configure()
//        Connectivity.shared.startListener()
        GMSPlacesClient.provideAPIKey(Keys.googleApiKey)
        guard GMSServices.provideAPIKey(Keys.googleApiKey) else { fatalError("Can not initialize Google Map services") }
    }

    private func configureAppLanguage() {
        let language = Locale.current.languageCode ?? Languages.english.rawValue
        LanguageService.setAppLanguageTo(lang: language)
    }

    private func saveKeysToKeychain() {
        UserTokenService.saveGoogleApiKey("AIzaSyC7_vpDhcpvC40bPqwNCaKBkL0bsXXYJUA")
        UserTokenService.saveBasicAuthKeyDebugMode("Basic am9kbnQ1eEtmUjBSYzFOeXNTNXpXOVg1VHVRYTpjUTBJTUNTdDU5YmtWcDMyTEkzb1B0MEJ5OHNh")
        UserTokenService.saveBasicAuthKeyStagingMode("Basic dEU2OUl4M3k2Tkk5Z0tuVmpMc0RVNGY3SlhJYTpDaUJyTTduTzJUOWpBaW5fVE1wM1ExeGUzazBh")
        UserTokenService.saveBasicAuthKeyProductionMode("Basic NnZ1dnZPa0x2ZkNYZ3d5WURJVlhQS2VXWUZvYTpHbEttTmxOVU91ZUJoek9La1dCUjg3MVhvbmNh")
    }
    
    private func configureRootViewController() {
        
        /*
        if currentLanguage == .arabic {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = UIStoryboard(name: "LaunchScreen_Ar", bundle: nil).instantiateInitialViewController()
            window?.makeKeyAndVisible()
        } else if currentLanguage == .urdu {
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = UIStoryboard(name: "LaunchScreen_Ur", bundle: nil).instantiateInitialViewController()
            window?.makeKeyAndVisible()
        }
        */
                
        window = UIWindow(frame: UIScreen.main.bounds)
        if AppDefaults.shared.didLaunchBefore {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
            self.window?.rootViewController = rootViewController
        } else {
            LanguageService.setAppLanguageTo(lang: Languages.arabic.rawValue)
            UIView.appearance().semanticContentAttribute = .forceRightToLeft
            let onBoardingViewController = LanguageSelectionViewController.instantiate(appStoryboard: .settings)
            let navigationController = UINavigationController(rootViewController: onBoardingViewController)
            navigationController.navigationBar.isHidden = true
            navigationController.navigationBar.items?.forEach { $0.backButtonTitle = emptyString }
            navigationController.navigationBar.tintColor = Colors.rptNavBackground
            navigationController.navigationBar.barTintColor = .white
            navigationController.navigationBar.shadowImage = UIImage()
            self.window?.rootViewController?.navigationController?.navigationBar.barTintColor = .white
            self.window?.rootViewController = navigationController
        }
        window?.makeKeyAndVisible()
        
        if let bound = self.window?.bounds {
            checkAppStatusAlert()
        }
        
        self.setNavigationBarAppearance()
    }
    
    
    private func checkAppStatusAlert() {
        let appUpdater = AppUpdateManager()
        appUpdater.getAppVersionStatus { infoModel in
            if let infoModel = infoModel {
                DispatchQueue.main.async {
                    switch appUpdater.returnAppCurrentStatus(model: infoModel) {
                    case .optional, .required:
                        self.showAlertForAppUpdate(title: Constants.newVersionTitle.localized, alertMessage: Constants.newVersionMessage.localized, firstButton: Constants.newVersionFirstBtn.localized, secondButton: emptyString)
                    case .noUpdate:
                        break
                    }
                    
                }
            }
        }
    }
    
    private func showAlertForAppUpdate(title: String, alertMessage: String, firstButton: String, secondButton: String) {
        
        guard let window = self.window else { return }
        
        let superWindowView = UIView(frame: window.frame)
        superWindowView.backgroundColor = .clear
        superWindowView.tag = 1111
        
        let alert = AlertDialogController(title: title, message: alertMessage)
        let firstAction = AlertAction(title: firstButton, style: .default) {
            DispatchQueue.main.async {
                self.updateApp()
            }
        }
        
        /*
        let secondAction = AlertAction(title: secondButton, true, style: .default) {
            DispatchQueue.main.async {
                if let window = self.window {
                    for windowView in window.subviews {
                        if windowView.tag == 1111 {
                            windowView.removeFromSuperview()
                        }
                    }
                }
            }
        }
        */
        
//        secondAction.setBackgroundImage(Images.grayButton, for: .normal)
//        secondAction.setTitleColor(Colors.rptDarkGreen, for: .normal)
        alert.addAction(firstAction)
        alert.view.frame = superWindowView.frame
        superWindowView.addSubview(alert.view)
        window.addSubview(superWindowView)
    }
    
    private func updateApp() {
        let appId = "1549817739"
        UIApplication.shared.openAppStore(for: appId)
    }

    func setNavigationBarAppearance (isNewRootViewControllerSet: Bool = false) {
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Colors.white
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        if UserDefaultService.getBrightness() != "" {
            UIScreen.main.brightness = CGFloat(Float(UserDefaultService.getBrightness()) ?? 0.5)
        }
        
        NotificationCenter.default.post(name: UIApplication.willResignActiveNotification, object: nil)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        UserDefaultService.setUserWentBackground(value: Date())
        mpTimer.invalidate()
        
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if UserDefaultService.getBarcodeView() {
            UIScreen.main.brightness = 1.0
        } else {
            UserDefaultService.setBarcodeView(value: false)
            if UserDefaultService.getBrightness() != "" {
                if UserDefaultService.getBrightness() != "\(UIScreen.main.brightness)" {
                    UserDefaultService.setBrightness(value: "\(UIScreen.main.brightness)")
                    UIScreen.main.brightness = CGFloat(Float(UserDefaultService.getBrightness()) ?? 0.5)
                } else {
                    UIScreen.main.brightness = CGFloat(Float(UserDefaultService.getBrightness()) ?? 0.5)
                }
            } else {
                UserDefaultService.setBrightness(value: "\(UIScreen.main.brightness)")
            }
        }
        let currentDate = Date()
        let lastDateObserved = UserDefaultService.getUserWentBackground()
        
        secondsElapsed = currentDate.timeIntervalSince(lastDateObserved ?? Date())
        print("Current Accumulated Time", Int(secondsElapsed))
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        if UserDefaultService.getBarcodeView() {
            UIScreen.main.brightness = 1.0
        } else {
            UserDefaultService.setBarcodeView(value: false)
            if UserDefaultService.getBrightness() != "" {
                if UserDefaultService.getBrightness() != "\(UIScreen.main.brightness)" {
                    UserDefaultService.setBrightness(value: "\(UIScreen.main.brightness)")
                    UIScreen.main.brightness = CGFloat(Float(UserDefaultService.getBrightness()) ?? 0.5)
                } else {
                    UIScreen.main.brightness = CGFloat(Float(UserDefaultService.getBrightness()) ?? 0.5)
                }
            } else {
                UserDefaultService.setBrightness(value: "\(UIScreen.main.brightness)")
            }
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

}
