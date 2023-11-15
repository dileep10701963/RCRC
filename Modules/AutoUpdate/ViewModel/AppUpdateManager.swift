//
//  AppUpdateManager.swift
//  RCRC
//
//  Created by Aashish Singh on 31/03/23.
//

import Foundation
import UIKit
import Alamofire

class AppUpdateManager {

    // MARK: - Enumerations
    enum Status {
        case required
        case optional
        case noUpdate
    }

    // MARK: - Initializers
    init(bundle: BundleType = Bundle.main) {
        self.bundle = bundle
    }
    
    func getAppVersionStatus(completionHandler : @escaping (iTunesInfo?) -> Void) {
        
        let request = AppInfoRequest()
        let bundleID = "sa.gov.rcrc.mp"
        
        let endPoint = EndPoint(baseUrl: .appInfo, methodName: "\(URLs.appInfoURL)\(bundleID)&country=sa", method: .get, encoder: URLEncodedFormParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: request, res: iTunesInfo.self) { result in
            switch result {
            case .success(let data):
                completionHandler(data)
            case .failure(let error):
                print("Error: \(error.localizedDescription)")
                completionHandler(nil)
            }
        }
    }
    
    
    func returnAppCurrentStatus(model: iTunesInfo) -> Status {
        
        let appVersionKey = "CFBundleShortVersionString"
        
        guard let appVersionValue = bundle.object(forInfoDictionaryKey: appVersionKey) as? String else {
            return .noUpdate
        }
        
        guard let appVersion = try? Version(from: appVersionValue) else {
            return .noUpdate
        }
        
        guard model.results.count > 0, let appInfo = model.results.first else {
            return .noUpdate
        }
        
        let appStoreVersion = appInfo.version
        
        var status: Status = .noUpdate
        let appVersionIntValue = Int("\(appVersion.major)\(appVersion.minor)\(appVersion.patch)") ?? 0
        let appStoreVersionValue = Int("\(appStoreVersion.major)\(appStoreVersion.minor)\(appStoreVersion.patch)") ?? 0

        if appVersionIntValue < appStoreVersionValue {
            status = .optional
        }
        /*if appVersion.major < appStoreVersion.major {
            status = .optional
        } else if appVersion.minor < appStoreVersion.minor {
            status = .optional
        } else if appVersion.patch < appStoreVersion.patch {
            status = .optional
        }*/
        return status
    }
    

    // MARK: - Public methods
//    func updateStatus(for bundleId: String) -> Status {
//
//
//        // Get the version of the app
//        let appVersionKey = "CFBundleShortVersionString"
//        guard let appVersionValue = bundle.object(forInfoDictionaryKey: appVersionKey) as? String else {
//            return .noUpdate
//        }
//
//        guard let appVersion = try? Version(from: appVersionValue) else {
//            return .noUpdate
//        }
//
//        // Get app info from App Store
//        let iTunesURL = URL(string: "http://itunes.apple.com/lookup?bundleId=\(bundleId)")
//
//        guard let url = iTunesURL else {
//            return .noUpdate
//        }
//
//        URLSession.shared.dataTask(with: url) { data, response, error in
//            DispatchQueue.main.async {
//                if let data = data {
//                    let decoder = JSONDecoder()
//                    decoder.dateDecodingStrategy = .iso8601
//
//                    guard let response = try? decoder.decode(iTunesInfo.self, from: data) else {
//                        return .noUpdate
//                    }
//
//                    guard response.results.count == 1, let appInfo = response.results.first else {
//                        return .noUpdate
//                    }
//
//                    let appStoreVersion = appInfo.version
//                    _ = appInfo.currentVersionReleaseDate
//
//                    let oneWeekInSeconds: TimeInterval = 7 * 24 * 60 * 60
//                    _ = Date(timeIntervalSinceNow: -oneWeekInSeconds)
//
//                    var status: Status = .noUpdate
//                    if appStoreVersion.major < appVersion.major {
//                        status = .required
//                    } else if appStoreVersion.minor < appVersion.minor {
//                        status = .optional
//                    } else if appStoreVersion.patch < appVersion.patch {
//                        status = .optional
//                    }
//                    return status
//                }
//            }
//        }.resume()
//
//    }

    // MARK: - Private properties
    private let bundle: BundleType
}

protocol BundleType {
    func object(forInfoDictionaryKey key: String) -> Any?
}

extension Bundle: BundleType {}

extension UIApplication {
    func openAppStore(for appID: String) {
        let appStoreURL = "https://itunes.apple.com/app/\(appID)"
        guard let url = URL(string: appStoreURL) else {
            return
        }

        DispatchQueue.main.async {
            if self.canOpenURL(url) {
                self.open(url)
            }
        }
    }
}
