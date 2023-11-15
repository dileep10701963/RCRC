//
//  AppDefaults.swift
//  RCRC
//
//  Created by Errol on 21/04/21.
//

import Foundation
import UIKit

class AppDefaults {

    static let shared = AppDefaults()

    private init() {}
    
    var isAppLaunched: Bool {
        get {
            if UserDefaults.standard.bool(forKey: Constants.guidelinesKey) {
                return true
            } else {
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.guidelinesKey)
        }
    }
    
    var isMapAPICalled: Bool {
        get {
            if UserDefaults.standard.bool(forKey: Constants.mapAPICalledKey) {
                return true
            } else {
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.mapAPICalledKey)
        }
    }
    
    var isAppVersionChecked: Bool {
        get {
            if UserDefaults.standard.bool(forKey: Constants.appVersionCheckedKey) {
                return true
            } else {
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.appVersionCheckedKey)
        }
    }

    var didLaunchBefore: Bool {
        get {
            if UserDefaults.standard.bool(forKey: Constants.didLaunchBeforeKey) {
                return true
            } else {
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.didLaunchBeforeKey)
        }
    }

    var isBiometricsEnabled: Bool {
        get {
            if UserDefaults.standard.bool(forKey: Constants.biometricsKey) {
                return true
            } else {
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.biometricsKey)
        }
    }

    var isUserLoggedIn: Bool {
        get {
            if UserDefaults.standard.bool(forKey: Constants.loginUserDefaultKey) {
                return true
            } else {
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.loginUserDefaultKey)
        }
    }
    
    var isTicketsVisited: Bool {
        get {
            if UserDefaults.standard.bool(forKey: Constants.isTicketVisited) {
                return true
            } else {
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Constants.isTicketVisited)
        }
    }
    
    var isBarcodeAvailableForOfflinePurpose: Bool {
        get {
            if UserDefaults.standard.bool(forKey: UserDefaultService.barcodesAvailableForOfflinePurpose) {
                return true
            } else {
                return false
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultService.barcodesAvailableForOfflinePurpose)
        }
    }
    
}
