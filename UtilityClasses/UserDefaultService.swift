//
//  UserDefaultService.swift
//  RCRC
//
//  Created by Aashish Singh on 18/08/22.
//

import Foundation

class UserDefaultService {

    static private let userNameKey = "UserNameKey"
    static private let brightnessKey = "BrightnessKey"
    static private let barcodeViewKey = "BarcodeViewKey"
    static private let countryCurrencyCodeKey = "CountryCurrencyCodeKey"
    static private let countryISOKey = "CountryISOKey"
    static private let barcodeFetchTime = "BarcodeFetchTime"
    static private let barcodeLastTime = "BarcodeLastTime"
    static private let allBarcodes = "AllBarcodes"
    static let barcodesAvailableForOfflinePurpose = "BarcodesAvailableForOfflinePurpose"
    static let userWentForeground = "UserWentForeground"
    static let userWentBackground = "UserWentBackground"
    static let barcodeCounter = "BarcodeCounter"
    static let lastVisitTime = "LastVisitTime"

    // MARK: - Get User Name
    class func getUserName() -> String {
        let userdef = UserDefaults.standard
        let userName = userdef.string(forKey: userNameKey) ?? ""
        return userName
    }

    // MARK: - Set User Name
    class func setUserName(userName: String) {
        let userdef = UserDefaults.standard
        userdef.set(userName, forKey: userNameKey)
        userdef.synchronize()
    }
    
    // MARK: - Delete User Name
    class func deleteUserName() {
        let userdef = UserDefaults.standard
        userdef.removeObject(forKey: userNameKey)
    }
    
    // MARK: - Get Brghtness
    class func getBrightness() -> String {
        let userdef = UserDefaults.standard
        let userName = userdef.string(forKey: brightnessKey) ?? ""
        return userName
    }

    // MARK: - Set Brightness
    class func setBrightness(value: String) {
        let userdef = UserDefaults.standard
        userdef.set(value, forKey: brightnessKey)
        userdef.synchronize()
    }
    
    // MARK: - Get CurrentViewController
    class func getBarcodeView() -> Bool {
        let userdef = UserDefaults.standard
        let isBarcodeView = userdef.bool(forKey: barcodeViewKey)
        return isBarcodeView
    }

    // MARK: - Set CurrentViewController
    class func setBarcodeView(value: Bool) {
        let userdef = UserDefaults.standard
        userdef.set(value, forKey: barcodeViewKey)
        userdef.synchronize()
    }
    
    // MARK: - Get Country Code
    class func getCountryCurrencyCode() -> String {
        let userdef = UserDefaults.standard
        let currencyCode = userdef.string(forKey: countryCurrencyCodeKey) ?? ""
        return currencyCode
    }

    // MARK: - Set Country Code
    class func setCountryCurrencyCode(value: String) {
        let userdef = UserDefaults.standard
        userdef.set(value, forKey: countryCurrencyCodeKey)
        userdef.synchronize()
    }
    
    // MARK: - Get Country ISO Code
    class func getCountryISOCode() -> String {
        let userdef = UserDefaults.standard
        let isoCode = userdef.string(forKey: countryISOKey) ?? ""
        return isoCode
    }

    // MARK: - Set Country ISO Code
    class func setCountryISOCode(value: String) {
        let userdef = UserDefaults.standard
        userdef.set(value, forKey: countryISOKey)
        userdef.synchronize()
    }
    
    // MARK: - Offline Barcode
    class func setBarcodeFetchTime(value: Date) {
        let userdef = UserDefaults.standard
        let dateString = value.toString(timeZone: .AST)
        userdef.set(dateString, forKey: barcodeFetchTime)
        userdef.synchronize()
    }
    
    class func getBarcodeFetchTime() -> Date {
        let userdef = UserDefaults.standard
        let barcodeFetchTimeString = userdef.string(forKey: barcodeFetchTime)
        guard let barcodeFetchTime = barcodeFetchTimeString?.toDate(timeZone: .AST) else { return Date() }
        return barcodeFetchTime
    }
    
    class func setTimeOfLastBarcode(value: Date) {
        let userdef = UserDefaults.standard
        let dateString = value.toString(timeZone: .AST)
        userdef.set(dateString, forKey: barcodeLastTime)
        userdef.synchronize()
    }
    
    class func getTimeOfLastBarcode() -> Date? {
        let userdef = UserDefaults.standard
        let barcodeFetchTimeString = userdef.string(forKey: barcodeLastTime)
        guard let barcodeFetchTime = barcodeFetchTimeString?.toDate(timeZone: .AST) else { return nil }
        return barcodeFetchTime
    }
    
    class func saveBarcodes(value: Data) {
        let userdef = UserDefaults.standard
        userdef.set(value, forKey: allBarcodes)
        userdef.synchronize()
    }
    
    class func getBarcodes() -> Data? {
        let userdef = UserDefaults.standard
        guard let allBarcodes = userdef.data(forKey: allBarcodes) else { return nil }
        return allBarcodes
    }
    
    class func setBarcodeAvailableForOfflinePurpose(value: Bool) {
        let userdef = UserDefaults.standard
        userdef.set(value, forKey: barcodesAvailableForOfflinePurpose)
        userdef.synchronize()
    }
    
    class func setUserWentBackground(value: Date?) {
        let userdef = UserDefaults.standard
        if value != nil {
            let dateString = value?.toString(timeZone: .AST)
            userdef.set(dateString, forKey: userWentBackground)
            userdef.synchronize()
        } else {
            userdef.set("", forKey: userWentBackground)
            userdef.synchronize()
        }
    }
    
    class func getUserWentBackground() -> Date? {
        let userdef = UserDefaults.standard
        let barcodeFetchTimeString = userdef.string(forKey: userWentBackground)
        guard let barcodeFetchTime = barcodeFetchTimeString?.toDate(timeZone: .AST) else { return Date() }
        return barcodeFetchTime
    }
    
    class func setUserWentForeground(value: Date?) {
        let userdef = UserDefaults.standard
        if value != nil {
            let dateString = value?.toString(timeZone: .AST)
            userdef.set(dateString, forKey: userWentForeground)
            userdef.synchronize()
        } else {
            userdef.set("", forKey: userWentForeground)
            userdef.synchronize()
        }
    }
    
    class func getUserWentForeground() -> Date? {
        let userdef = UserDefaults.standard
        let barcodeFetchTimeString = userdef.string(forKey: userWentForeground)
        guard let barcodeFetchTime = barcodeFetchTimeString?.toDate(timeZone: .AST) else { return Date() }
        return barcodeFetchTime
    }
    
    class func getBarcodeCounter() -> Int {
        let userdef = UserDefaults.standard
        let barcodeCounter = userdef.integer(forKey: barcodeCounter)
        return barcodeCounter
    }

    // MARK: - Set Country ISO Code
    class func setBarcodeCounter(value: Int) {
        let userdef = UserDefaults.standard
        userdef.set(value, forKey: barcodeCounter)
        userdef.synchronize()
    }
    
    class func setLastVisitTime(value: Date?) {
        let userdef = UserDefaults.standard
        if value != nil {
            let dateString = value?.toString(timeZone: .AST)
            userdef.set(dateString, forKey: lastVisitTime)
            userdef.synchronize()
        } else {
            userdef.set("", forKey: lastVisitTime)
            userdef.synchronize()
        }
    }
    
    class func getLastVisitTime() -> Date? {
        let userdef = UserDefaults.standard
        let lastVisitTimeString = userdef.string(forKey: lastVisitTime)
        guard let lastVisitTime = lastVisitTimeString?.toDate(timeZone: .AST) else { return Date() }
        return lastVisitTime
    }
}
