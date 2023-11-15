//
//  LoginModel.swift
//  RCRC
//
//  Created by Errol on 21/04/21.
//

import Foundation

struct LoginModel: Encodable {
    var user: String?
    var password: String?
}

struct LoginRequestParameters: Encodable {
    var xAfcLang: String = AFCAPIHeaders.afcLanguage

    enum CodingKeys: String, CodingKey {
        case xAfcLang = "X-AFC-Lang"
    }
}

struct LoginResponseModel: Decodable {
    var token: String?
    var message: String?
    var timestamp: String?
    var details: String?
}

struct Wso2TokenResponse: Codable {
    let accessToken, scope, tokenType: String?
    let expiresIn: Int?

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case scope
        case tokenType = "token_type"
        case expiresIn = "expires_in"
    }
}
