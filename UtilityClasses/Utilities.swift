//
//  Utilities.swift
//  RCRC
//
//  Created by Errol on 11/08/20.
//

import Foundation
import Alamofire
import UIKit

class Connectivity {
    static let shared = Connectivity()
    let reachabilityManager = NetworkReachabilityManager()
    let offlineViewController = OfflineViewController.instantiate(appStoryboard: .main)

    func startListener() {
        reachabilityManager?.startListening(onUpdatePerforming: { (status) in
            switch status {
            case .notReachable: break
                self.offlineViewController.dismiss(animated: false, completion: nil)
                self.offlineViewController.modalPresentationStyle = .fullScreen
                UIApplication.shared.keyWindow?.rootViewController?.present(self.offlineViewController, animated: true, completion: nil)
            case .reachable(.cellular):
                self.offlineViewController.dismiss(animated: false, completion: nil)
            case .reachable(.ethernetOrWiFi):
                self.offlineViewController.dismiss(animated: false, completion: nil)
            case .unknown:
                break
            }
        })
    }

    var isConnected: Bool {
        if let isReachable = reachabilityManager?.isReachable {
            return isReachable
        } else {
            return false
        }
    }
}

class Utilities {

    static let shared = Utilities()

    private init() {}

    func getAttributedText(_ firstString: String?,
                           _ secondString: String?,
                           _ firstFont: UIFont = Fonts.CodecBold.thirteen,
                           _ secondFont: UIFont = Fonts.CodecNews.twelve,
                           _ firstColor: UIColor = Colors.textColor , _ isNewLineWithTime: Bool = false, _ secondColor: UIColor = Colors.textColor) -> NSMutableAttributedString {
        let stopNameAttribute = [NSAttributedString.Key.font: firstFont, NSAttributedString.Key.foregroundColor: firstColor]
        let stopAddressAttribute = [NSMutableAttributedString.Key.font: secondFont, NSMutableAttributedString.Key.foregroundColor: secondColor]
        let commaWord = secondString ?? nil == nil || secondString == "" ? "": ", "
        let stopName = NSMutableAttributedString(string: (firstString ?? "") + commaWord, attributes: stopNameAttribute as [NSAttributedString.Key: Any])
        
        var secondStrings: String = emptyString
        if isNewLineWithTime {
            secondStrings = "\n\(secondString ?? emptyString)"
        } else {
            secondStrings = secondString ?? emptyString
        }
        let stopAddress = NSMutableAttributedString(string: secondStrings, attributes: stopAddressAttribute as [NSAttributedString.Key: Any])
        stopName.append(NSAttributedString(string: " "))
        stopName.append(stopAddress)
        return stopName
    }

    func getAttributedText(firstString: String?,
                           secondString: String?,
                           firstFont: (font: UIFont, color: UIColor),
                           secondFont: (font: UIFont, color: UIColor)) -> NSMutableAttributedString {
        let firstStringAttributes = [NSAttributedString.Key.font: firstFont.font, .foregroundColor: firstFont.color]
        let secondStringAttributes = [NSMutableAttributedString.Key.font: secondFont.font, NSMutableAttributedString.Key.foregroundColor: secondFont.color]
        let firstAttributedString = NSMutableAttributedString(string: firstString ?? "", attributes: firstStringAttributes as [NSAttributedString.Key: Any])
        let secondAttributedString = NSMutableAttributedString(string: secondString ?? "", attributes: secondStringAttributes as [NSAttributedString.Key: Any])
        firstAttributedString.append(secondAttributedString)
        return firstAttributedString
    }
    
    func getAttributedText(firstString: String?,
                           secondString: String?,
                           thirdString: String?,
                           firstFont: (font: UIFont, color: UIColor),
                           secondFont: (font: UIFont, color: UIColor),
                           thirdFont: (font: UIFont, color: UIColor)) -> NSMutableAttributedString {
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        
        let firstStringAttributes = [NSAttributedString.Key.font: firstFont.font, .foregroundColor: firstFont.color, .paragraphStyle: paragraphStyle]
        let secondStringAttributes = [NSMutableAttributedString.Key.font: secondFont.font, .foregroundColor: secondFont.color, .paragraphStyle: paragraphStyle]
        let thirdStringAttributes = [NSMutableAttributedString.Key.font: thirdFont.font, .foregroundColor: thirdFont.color, .paragraphStyle: paragraphStyle]
        
        let firstAttributedString = NSMutableAttributedString(string: firstString ?? "", attributes: firstStringAttributes as [NSAttributedString.Key: Any])
        let secondAttributedString = NSMutableAttributedString(string: secondString ?? "", attributes: secondStringAttributes as [NSAttributedString.Key: Any])
        let thirdAttributedString = NSMutableAttributedString(string: thirdString ?? "", attributes: thirdStringAttributes as [NSAttributedString.Key: Any])

        firstAttributedString.append(secondAttributedString)
        firstAttributedString.append(thirdAttributedString)
        return firstAttributedString
    }

    /// Get Universal Unique Identifier of Device
    /// - Returns: UUID
    static func getUuid() -> String? {
        guard let uuid = UIDevice.current.identifierForVendor?.uuidString else {
            return nil
        }
        return uuid
    }

    static func authenticate(viewController: UIViewController) {

        let authenticationViewController = TouchIDAuthenticationViewController()
        authenticationViewController.modalPresentationStyle = .fullScreen
        authenticationViewController.modalTransitionStyle = .crossDissolve
        viewController.present(authenticationViewController, animated: false)
    }

    class Connectivity {

        /// Show Alert if device is not connected to Internet
        /// - Parameter viewController: UIViewController where the alert is to be displayed
        static func isConnectedToInternet(viewController: UIViewController? = nil) -> Bool {
//            if !NetworkReachabilityManager()!.isReachable {
                //viewController.showAlert(for: .noInternet)
//            }
            if NetworkReachabilityManager()!.isReachable {
                return true
            } else {
                showToast(Constants.youAreOffline.localized)
                return false
            }
        }
        
        static func showToast(_ message: String) {
            DispatchQueue.main.async {
                if let viewController: UIWindow = (UIApplication.shared.delegate?.window)! {
                    var toastLabel = UILabel()
                    if currentLanguage == .arabic {
                        toastLabel = UILabel(frame: CGRect(x: viewController.frame.size.width/2 - 100, y: viewController.frame.size.height-150, width: 200, height: 35))
                    } else {
                        toastLabel = UILabel(frame: CGRect(x: viewController.frame.size.width/2 - 75, y: viewController.frame.size.height-150, width: 150, height: 35))
                    }
                    toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
                    toastLabel.textColor = UIColor.white
                    toastLabel.font = Fonts.RptaSignage.fifteen
                    toastLabel.textAlignment = .center
                    toastLabel.text = message
                    toastLabel.alpha = 1.0
                    toastLabel.layer.cornerRadius = 10
                    toastLabel.clipsToBounds  =  true
                    viewController.addSubview(toastLabel)
                    UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
                        toastLabel.alpha = 0.0
                    }, completion: {(_) in
                        toastLabel.removeFromSuperview()
                    })
                }
            }
        }
    }

    class DateTime {

        static func getCurrentTime(timeZone: TimeZones, format: String) -> String {

            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = Constants.am
            dateFormatter.pmSymbol = Constants.pm
            dateFormatter.timeZone = TimeZone(secondsFromGMT: timeZone.rawValue)
            dateFormatter.locale = Locale(identifier: "en_US")
            dateFormatter.dateFormat = format
            let timeString = dateFormatter.string(from: date)
            return timeString
        }

        static func getCurrentDate(timeZone: TimeZones, format: String) -> String {

            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.timeZone = TimeZone(secondsFromGMT: timeZone.rawValue)
            dateFormatter.dateFormat = format
            dateFormatter.locale = Locale(identifier: "en_US")
            let dateString = dateFormatter.string(from: date)
            return dateString
        }

        static func fetchFiveDatesFromNow() -> [Date] {

            let calendar = Calendar(identifier: .gregorian)
            var days = [Date]()
            let currDate = Date()
            for i in 0...4 {
                let newDate = calendar.date(byAdding: .day, value: i, to: currDate)!
                let day = newDate
                days.append(day)
            }
            return days
        }
    }

    static func atrributedText(titleLabel: String, subTitleLabel: String) -> NSAttributedString {
        let attributedKeyFirst = [NSAttributedString.Key.font: Fonts.RptaSignage.sixteen, NSAttributedString.Key.foregroundColor: UIColor.black]
        let attributedKeySecond = [NSAttributedString.Key.font: Fonts.RptaSignage.fourteen, NSAttributedString.Key.foregroundColor: UIColor(red: 138.0 / 255.0, green: 141.0 / 255.0, blue: 143.0 / 255.0, alpha: 1.0)]
        let attributedStringOne = NSMutableAttributedString(string: titleLabel, attributes: attributedKeyFirst as [NSAttributedString.Key: Any])
        let attributedStringSecond = NSMutableAttributedString(string: subTitleLabel, attributes: attributedKeySecond as [NSAttributedString.Key: Any])
        attributedStringOne.append(attributedStringSecond)
        return attributedStringOne
    }

    static func getProfileImage(_ data: Data?) -> UIImage {
        if let data = data, let image = UIImage(data: data) {
            return image
        } else {
            return Images.profileImagePlaceholder ?? UIImage()
        }
    }
}
