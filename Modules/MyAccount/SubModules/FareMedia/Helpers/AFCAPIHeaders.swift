//
//  AFCAPIHeaders.swift
//  RCRC
//
//  Created by Errol on 03/08/21.
//

import Foundation
import Alamofire

struct AFCAPIHeaders {

    static var afcLanguage: String {
        switch currentLanguage {
        case .english:
            return "en_GB"
        case .arabic:
            return "ar_SA"
        case .urdu:
            return "ur_PK"
        }
    }

    static func generateAuthenticated() throws -> HTTPHeaders {
        guard let loginToken = UserTokenService.retrieve() else {
            throw FareMediaError.notLoggedIn
        }
        let headers: HTTPHeaders = [
            HTTPHeader(name: "Authorization", value: UserTokenService.retrieveWsoToken()),
            HTTPHeader(name: "Accept", value: "application/json"),
            HTTPHeader(name: "X-AFC-Lang", value: AFCAPIHeaders.afcLanguage),
            HTTPHeader(name: "X-AFC-Auth", value: loginToken),
            HTTPHeader(name: "Cache-Control", value: "no-cache, no-store, max-age=0, must-revalidate")
        ]
        return headers
    }

    static func generatePublic() -> HTTPHeaders {
        let headers: HTTPHeaders = [
            HTTPHeader(name: "Authorization", value: UserTokenService.retrieveWsoToken()),
            HTTPHeader(name: "Accept", value: "application/json"),
            HTTPHeader(name: "X-AFC-Lang", value: AFCAPIHeaders.afcLanguage),
            HTTPHeader(name: "Cache-Control", value: "no-cache, no-store, max-age=0, must-revalidate")
        ]
        return headers
    }
}
