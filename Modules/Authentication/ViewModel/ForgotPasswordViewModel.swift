//
//  ForgotPasswordViewModel.swift
//  RCRC
//
//  Created by Aashish Singh on 08/07/22.
//

import Foundation

class ForgotPasswordViewModel: NSObject {

    var email: String?
    
    func isEmailValid() -> Bool {
        return Validation.shared.isValidEmail(email: email ?? emptyString)
    }

    func forgotPassword(userName: String, completion: @escaping (LoginResult) -> Void) {
        AuthenticationService.forgotPassword(username: userName, completion: completion)
    }
}
