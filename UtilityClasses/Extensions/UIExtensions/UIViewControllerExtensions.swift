//
//  UIStoryboardExtension.swift
//  RCRC
//
//  Created by Ganesh Shinde on 24/07/20.
//

import UIKit
import Firebase

extension UIViewController {

    // MARK: - UIViewController Extension to instantiate ViewController from Different storyboard file.
    static func instantiate<T: UIViewController>(appStoryboard: StoryModule) -> T {

        let storyboard = UIStoryboard(name: appStoryboard.rawValue, bundle: nil)
        let identifier = String(describing: self)
        return storyboard.instantiateViewController(withIdentifier: identifier) as? T ?? T()
    }

    func delay(_ delay: Double, completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: completion)
    }
    
    func startActivityIndicator() -> UIActivityIndicatorView {
        for view in self.view.subviews {
            if view.isKind(of: UIActivityIndicatorView.self) {
                view.removeFromSuperview()
            }
        }
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = self.view.center
        activityView.color = Colors.rptGreen
        activityView.hidesWhenStopped = true
        DispatchQueue.main.async {
            self.view.addSubview(activityView)
            activityView.startAnimating()
        }
        return activityView
    }

    func showAlert(for alertType: AlertTypes) {

        switch alertType {
        case .noInternet:
            showCustomAlert(alertTitle: Constants.noInternetAlertTitle.localized,
                            alertMessage: Constants.noInternetAlertMessage.localized,
                            firstActionTitle: ok.localized,
                            secondActionTitle: Constants.goToSettings.localized,
                            secondActionStyle: .default, secondActionHandler: {
                                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                                    return
                                }
                                if UIApplication.shared.canOpenURL(settingsUrl) {
                                    UIApplication.shared.open(settingsUrl, completionHandler: nil)
                                }
                            })

        case .serverError:
            showCustomAlert(alertTitle: Constants.serverErrorAlertTitle.localized,
                            alertMessage: Constants.serverErrorAlertMessage.localized,
                            firstActionTitle: ok)

        case .cameraError:
            showCustomAlert(alertTitle: Constants.cameraErrorAlertTitle,
                            alertMessage: Constants.cameraErrorAlertMessage,
                            firstActionTitle: ok)

        case .loading:
            let dialog = ProgressDialogController(title: Constants.loadingTitle)
            DispatchQueue.main.async {
                self.present(dialog, animated: true, completion: nil)
            }
        case .invalidToken:
            self.showCustomAlert(alertTitle: Constants.sessionExpiredTitle, alertMessage: Constants.sessionExpiredError, firstActionTitle: ok, firstActionStyle: .default, secondActionTitle: nil, secondActionStyle: nil, firstActionHandler: {
                DispatchQueue.main.async {
                    AppDefaults.shared.isUserLoggedIn = false
//                    UserProfileDataRepository.shared.delete()
                    UserDefaultService.deleteUserName()
                    self.navigateToDashboard()
                }
            }, secondActionHandler: nil)
        }
    }

    func showDateTimePicker(okButtonAction: ((MPDateTimePickerSelection) -> Void)? = nil) {
        let alert = MPDateTimePicker(title: "")
        alert.returnValue = { selections in
            print("My Selected values",selections)
            okButtonAction?(selections)
            alert.dismiss(animated: true, completion: nil)
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showDatePicker(startDate: Date, okButtonAction: ((MPDatePickerSelection) -> Void)? = nil) {
        let alert = MPDatePickerViewController(title: "", startDate: startDate)
        alert.returnValue = { selections in
            print("My Selected values",selections)
            okButtonAction?(selections)
            alert.dismiss(animated: true, completion: nil)
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showCustomAlert(alertTitle: String, alertMessage: String, firstActionTitle: String, firstActionStyle: AlertActionStyle = .default, secondActionTitle: String? = nil, secondActionStyle: AlertActionStyle? = nil, firstActionHandler: (() -> Void)? = nil, secondActionHandler: (() -> Void)? = nil) {

        let alert = AlertDialogController(title: alertTitle, message: alertMessage)
        if let secondActionTitle = secondActionTitle, let secondActionStyle = secondActionStyle {
            let firstAction = AlertAction(title: firstActionTitle, style: firstActionStyle) {
                if let firstActionHandler = firstActionHandler {
                    firstActionHandler()
                }
            }

            let secondAction = AlertAction(title: secondActionTitle, true, style: secondActionStyle) {
                if let secondActionHandler = secondActionHandler {
                    secondActionHandler()
                }
            }

            secondAction.setBackgroundImage(Images.grayButton, for: .normal)
            secondAction.setTitleColor(Colors.rptDarkGreen, for: .normal)
            alert.addAction(firstAction)
            alert.addAction(secondAction)
        } else {

            let firstAction = AlertAction(title: firstActionTitle, style: firstActionStyle) {
                if let firstActionHandler = firstActionHandler {
                    firstActionHandler()
                }
            }
            alert.addAction(firstAction)
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }

    func showScrollableAlert(alertTitle: String = "Terms and Conditions", alertMessage: String = Constants.privacyPolicy, firstActionHandler: (() -> Void)? = nil) {
        let alert = ScrollableAlertView(title: alertTitle, message: alertMessage)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func showScrollableAlertWithAttributedContent(alertTitle: String, alertMessage: NSMutableAttributedString, buttonTitle: String = emptyString, actionHandler: (() -> Void)? = nil) {
        let alert = ScrollableAlertView(title: alertTitle, attributedMessage: alertMessage, buttonTitle: buttonTitle)
        alert.action = {
            alert.dismiss(animated: true)
            actionHandler?()
        }
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func configureNavigationBar(title: String?, backgroundColor: UIColor = Colors.green, textColor: UIColor = .white, font: UIFont? = Fonts.RptaSignage.eighteen, showBackButton: Bool = false) {
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationItem.title = emptyString
        
        if self.superclass != ContentViewController.classForCoder() || showBackButton == true {
            let subViews = self.navigationController?.navigationBar.subviews
            if let subviews = subViews {
                for subView in subviews where subView.tag == 1010 || subView.tag == 1040 || subView.tag == 1090 {
                    subView.removeFromSuperview()
                }
            }
            
            let backButtonItem = UIButton(type: .custom)
            backButtonItem.setImage(Images.backButtonBlack?.setNewImageAsPerLanguage(), for: .normal)
            backButtonItem.contentMode = .scaleAspectFill
            backButtonItem.backgroundColor = .clear
            backButtonItem.tintColor = Colors.rptNavButtonGreen
            backButtonItem.tag = 1020
            backButtonItem.addTarget(self, action: #selector(backButtonTapped(sender:)), for: .touchUpInside)
            
            let logoImageView = UIImageView()
            logoImageView.translatesAutoresizingMaskIntoConstraints = false
            logoImageView.contentMode = .scaleToFill
            logoImageView.clipsToBounds = true
            logoImageView.tag = 1030
            logoImageView.image = Images.navigationLogo
            
            var maxy = self.navigationController?.navigationBar.frame.height ?? 0
            maxy = maxy - (35 + 4)
            
            let englishX: CGFloat = 20
            let arabicX: CGFloat = UIScreen.main.bounds.width - 55
            
            backButtonItem.frame = CGRect(x: currentLanguage == .english ? englishX: arabicX, y: maxy, width: 35, height: 35)
            
            if let subviews = subViews {
                if subviews.contains(where: {$0.tag == 1020}) {
                    // Do not add
                } else {
                    self.navigationController?.navigationBar.addSubview(backButtonItem)
                }
            } else {
                self.navigationController?.navigationBar.addSubview(backButtonItem)
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
        
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.hidesBackButton = true
    }
    
    func hideNavigationBarBackButton() {
        let subViews = self.navigationController?.navigationBar.subviews
        if let subviews = subViews {
            for subView in subviews where subView.tag == 1020 {
                subView.removeFromSuperview()
            }
        }
    }
    
    private func addNavigationViewAndCostraint(imageView: UIImageView) {
        self.navigationController?.navigationBar.addSubview(imageView)
        
        imageView.centerXAnchor.constraint(equalTo: (self.navigationController?.navigationBar.centerXAnchor)!).isActive = true
        imageView.centerYAnchor.constraint(equalTo: (self.navigationController?.navigationBar.centerYAnchor)!).isActive = true
    }
    
    
    @objc func backButtonTapped(sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func showToast(_ message: String) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = Fonts.RptaSignage.fifteen
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
             toastLabel.alpha = 0.0
        }, completion: {(_) in
            toastLabel.removeFromSuperview()
        })
    }

    func attributedText(text: String?, lineSapcing:CGFloat = 3) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSapcing // Whatever line spacing you want in points
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    func addBackgroundImage() {
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        backgroundImage.contentMode = .bottomRight
        backgroundImage.image = Images.backgroundLogo
        self.view.insertSubview(backgroundImage, at: 0)
    }

    func makeNavigationBarTransparent() {
        navigationController?.navigationBar.items?.forEach({ $0.backButtonTitle = emptyString })
        navigationController?.navigationBar.tintColor = Colors.rptNavButtonGreen
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.backgroundColor = .white
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    func makeNavigationBarGreen() {
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = Colors.white
        navigationController?.navigationBar.backgroundColor = Colors.white
        navigationController?.navigationBar.shadowImage = nil
    }

    func showAlertWithTextField(title: String, message: String, placeholder: String, enteredText: @escaping (String) -> Void, onSave: @escaping () -> Void) {
        let alertController = AlertDialogTextField(title: title, message: message, placeholder: placeholder, action: enteredText, onSave: onSave)
        present(alertController, animated: true, completion: nil)
    }

    func showUpdateTextAlert(title: String, message: String, placeholder: String, textToEdit: String, enteredText: @escaping (String) -> Void, onSave: @escaping () -> Void) {
        let alertController = AlertDialogTextField(title: title, message: message, placeholder: placeholder, editText: textToEdit, action: enteredText, onSave: onSave)
        present(alertController, animated: true, completion: nil)
    }
    
    // Log Event for Every screen (Analytics)
    func logEvent(screen: ScreenName) {
        let viewControllerName = String(describing: type(of: self))
        Analytics.logEvent(screen.rawValue, parameters: [AnalyticsParameterScreenName: screen.rawValue, AnalyticsParameterScreenClass: viewControllerName])
    }
    
    func navigateToDashboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "root")
        rootViewController.navigationController?.navigationBar.barTintColor = Colors.white
        rootViewController.navigationController?.navigationBar.backgroundColor = Colors.white
        rootViewController.navigationController?.navigationBar.tintColor = .white
        appDelegate?.changeRootViewController(rootViewController, animated: true)
    }
    
    func setNavigationBarAppearance (isPrimaryColorSet: Bool = true) {
        if #available(iOS 13, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Colors.white
            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            appearance.shadowColor = .clear
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
//            self.navigationController?.navigationBar.prefersLargeTitles = true
//            self.navigationController?.navigationItem.largeTitleDisplayMode = .always
//            self.navigationController?.navigationBar.topItem?.title = ""
//            
        }
    }
    
    func disableUserInteractionWhenAPICalls() {
        self.view.isUserInteractionEnabled = false
        self.navigationController?.navigationBar.isUserInteractionEnabled = false
    }
    
    func enableUserInteractionWhenAPICalls() {
        self.view.isUserInteractionEnabled = true
        self.navigationController?.navigationBar.isUserInteractionEnabled = true
    }
    
    func disableLargeNavigationTitleCollapsing() {
        let tempView = UIView()
        view.addSubview(tempView)
        view.sendSubviewToBack(tempView)
    }
    
}

// Add you modules here. Make sure rawValues refer to a stroyboard file name.
enum StoryModule: String {
    case main = "Main"
    case contactInformation = "ContactInformationScene"
    case reportIncidence = "ReportIncidenceScene"
    case reportIncidence1 = "ReportIncidenceScene1"
    case frequentlyAskedQuestions = "FrequentlyAskedQuestionViewScene"
    case settings = "SettingsScene"
    case availableRoutes = "AvailableRoutesScene"
    case routeSelection = "RouteSelectionScene"
    case home = "HomeViewScene"
    case search = "SearchViewScene"
    case searchModule = "SearchModule"
    case news = "NewsViewScene"
    case myAccount = "MyAccountScene"
    case message = "MessageView"
    case profile = "ProfileViewScene"
    case correspondence = "CorrespondenceViewScene"
    case authentication = "LoginModule"
    case onBoarding = "OnBoarding"
    case quickResponseCodeGenerator = "QuickResponseCodeGenerator"
    case aboutKRPT = "AboutKRPTScene"
    case fareMedia = "FareMediaViewScene"
    case cardOption = "CardOptionViewScene"
    case reusableSuccess = "SuccessScene"
    case sendQuery = "SendQueryScene"
    case notification = "NotificationScene"
    case homeWorkFavorites = "HomeWorkFavorites"
    case busNetwork = "BusNetworkScene"
    case fareTicketing = "FareTicketingScene"
    case kaprptInfo = "KAPRPTInfoViewController"
    case tickets = "FareMediaViewController"
}

extension UICollectionViewCell {
    func startActivityIndicator() -> UIActivityIndicatorView {
        let activityView = UIActivityIndicatorView(style: .whiteLarge)
        activityView.center = self.contentView.center
        activityView.color = Colors.green
        activityView.hidesWhenStopped = true
        DispatchQueue.main.async {
            self.contentView.addSubview(activityView)
            activityView.startAnimating()
        }
        return activityView
    }

}
