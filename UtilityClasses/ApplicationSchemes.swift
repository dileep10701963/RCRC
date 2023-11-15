//
//  ApplicationQuerySchemes.swift
//  RCRC
//
//  Created by Errol on 21/09/20.
//

import Foundation
import UIKit

class ApplicationSchemes: NSObject {

    static let shared = ApplicationSchemes()

    func openInBrowser(_ url: String) {
        let webURL = URL(string: url)!
        let application = UIApplication.shared
        application.open(webURL)
    }

    func open(_ name: Applications) {

        switch name {

        case .instagram:
            let username =  "riyadhtransport"
            let appURL = URL(string: URLs.ApplicationSharing.instagramApp + username)!
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                let webURL = URL(string: URLs.ApplicationSharing.instagramWeb + username)!
                application.open(webURL)
            }
        case .facebook:
            let username =  "riyadhtransport"
            let appURL = URL(string: URLs.ApplicationSharing.facebookApp + username)!
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                let webURL = URL(string: URLs.ApplicationSharing.facebookWeb + username)!
                application.open(webURL)
            }
        case .twitter:
            let username =  "RiyadhTransport"
            let appURL = URL(string: URLs.ApplicationSharing.twitterApp + username)!
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                let webURL = URL(string: URLs.ApplicationSharing.twitterWeb + username)!
                application.open(webURL)
            }

        case .youtube:
            let username =  "ArRiyadhADA"
            let appURL = URL(string: URLs.ApplicationSharing.youtubeApp + username)!
            let application = UIApplication.shared

            if application.canOpenURL(appURL) {
                application.open(appURL)
            } else {
                let webURL = URL(string: URLs.ApplicationSharing.youtubeWeb + username)!
                application.open(webURL)
            }
        }
    }
}

enum Applications {

    case instagram
    case facebook
    case twitter
    case youtube
}
