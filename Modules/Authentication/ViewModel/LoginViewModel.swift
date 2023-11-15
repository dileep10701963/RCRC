//
//  LoginViewModel.swift
//  RCRC
//
//  Created by Errol on 15/01/21.
//

import Foundation
import Alamofire

typealias KeychainResult = Bool
typealias KeychainKey = String

enum LoginResult: Equatable {
    case success
    case failure(String)
}

class LoginViewModel: NSObject {

    var email: String?
    var password: String?

    func isPasswordValid() -> Bool {
        return Validation.shared.isValidPassword(password: password ?? emptyString)
    }

    func isEmailValid() -> Bool {
        return Validation.shared.isValidEmail(email: email ?? emptyString)
    }

    func login(user: String, password: String, completion: @escaping (LoginResult) -> Void) {
        AuthenticationService.login(username: user, password: password, completion: completion)
    }
}
