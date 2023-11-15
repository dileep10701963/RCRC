//
//  AuthenticationService.swift
//  RCRC
//
//  Created by Errol on 02/08/21.
//

import Foundation
import Alamofire

struct AuthenticationService {
    static func login(username: String, password: String, completion: @escaping (LoginResult) -> Void) {
        let endPoint = EndPoint(baseUrl: .login, methodName: URLs.loginEndpoint, method: .post, encoder: JSONParameterEncoder.default)
        let parameters = LoginModel(user: username, password: password)

        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: LoginResponseModel.self) { result in
            switch result {
            case let .success((data, response)):
                let isStatusCode200 = response.statusCode == 200
                if let token = data?.token, isStatusCode200 {
                    UserTokenService.save(token)
                    UserTokenService.savePassword(password)
                    UserDefaultService.setUserName(userName: username)
                    completion(.success)
                } else {
                    completion(.failure(data?.message ?? Constants.loginFailedError))
                }
            case .failure:
                completion(.failure(Constants.loginFailedError))
            }
        }
    }

    static func logout(completion: @escaping (LogoutResult) -> Void) {
        let endpoint = EndPoint(baseUrl: .logout, methodName: URLs.logoutEndpoint, method: .post, encoder: URLEncodedFormParameterEncoder.default)
        struct DefaultParameters: Encodable {}
        let parameters = DefaultParameters()
        ServiceManager.sharedInstance.withRequest(endPoint: endpoint, parameters: parameters, resultData: LogoutModel.self) { result in
            switch result {
            case let .success((data, response)):
                let logoutSuccess = response.statusCode == 200
                logoutSuccess ? completion(.success) : completion(.failure(data))
            case .failure:
                completion(.networkFailure(.connectivity))
            }
        }
    }

    static func retryLogin(completion: @escaping (LoginResult) -> Void) {
        AuthenticationService.login(username: UserDefaultService.getUserName(), password: UserTokenService.retrievePassword() ?? "", completion: completion)
    }
    
    static func forgotPassword(username: String, completion: @escaping (LoginResult) -> Void) {
        
        let endPoint = EndPoint(baseUrl: .forgotPassword, methodName: URLs.forgotPasswordEndPoint, method: .put, encoder: JSONParameterEncoder.default)
        let parameters = ForgotPasswordModel(userName: username)
        
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: ErrorResponseModel.self) { result in
            switch result {
            case let .success((data, response)):
                let isStatusCode200 = response.statusCode == 200
                if isStatusCode200 {
                    completion(.success)
                } else {
                    completion(.failure(data?.message ?? Constants.loginFailedError))
                }
            case .failure:
                completion(.failure(Constants.loginFailedError))
            }
        }
        
    }
    
    static func signUp(signUpModel: SignUpModel, completion: @escaping (LoginResult) -> Void) {
        
        let endPoint = EndPoint(baseUrl: .signUp, methodName: URLs.signUpEndPoint, method: .post, encoder: JSONParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: signUpModel, resultData: LoginResponseModel.self) { result in
            switch result {
            case let .success((data, response)):
                let isStatusCode200 = response.statusCode == 200
                if isStatusCode200 {
                    completion(.success)
                } else {
                    completion(.failure(data?.message ?? Constants.serverErrorAlertMessage.localized))
                }
            case .failure:
                completion(.failure(Constants.serverErrorAlertMessage.localized))
            }
        }
    }
}

struct UserTokenService {
    static func save(_ token: String) {
        KeychainWrapper.standard.set(token, forKey: Constants.userLoginTokenKey)
    }

    static func retrieve() -> String? {
        return KeychainWrapper.standard.string(forKey: Constants.userLoginTokenKey)
    }
    
    static func saveWsoToken(_ token: String) {
        KeychainWrapper.standard.set(token, forKey: Constants.userWsoTokenKey)
    }

    static func retrieveWsoToken() -> String {
        return KeychainWrapper.standard.string(forKey: Constants.userWsoTokenKey) ?? ""
    }
    
    // google key
    static func saveGoogleApiKey(_ key: String) {
        KeychainWrapper.standard.set(key, forKey: Constants.googleApiKey)
    }

    static func retrieveGoogleApiKey() -> String? {
        return KeychainWrapper.standard.string(forKey: Constants.googleApiKey)
    }
    
    // basic auth key DEBUG
    static func saveBasicAuthKeyDebugMode(_ authKey: String) {
        KeychainWrapper.standard.set(authKey, forKey: Constants.basicAuthKeyDebugMode)
    }

    static func retrieveBasicAuthKeyDebugMode() -> String? {
        return KeychainWrapper.standard.string(forKey: Constants.basicAuthKeyDebugMode)
    }
    
    // basic auth key Staging
    static func saveBasicAuthKeyStagingMode(_ authKey: String) {
        KeychainWrapper.standard.set(authKey, forKey: Constants.basicAuthKeyStagingMode)
    }

    static func retrieveBasicAuthKeyStagingMode() -> String? {
        return KeychainWrapper.standard.string(forKey: Constants.basicAuthKeyStagingMode)
    }
    
    // basic auth key Production
    static func saveBasicAuthKeyProductionMode(_ authKey: String) {
        KeychainWrapper.standard.set(authKey, forKey: Constants.basicAuthKeyProductionMode)
    }

    static func retrieveBasicAuthKeyProductionMode() -> String? {
        return KeychainWrapper.standard.string(forKey: Constants.basicAuthKeyProductionMode)
    }
    
    // basic auth key Staging
    static func savePassword(_ password: String) {
        KeychainWrapper.standard.set(password, forKey: Constants.passwordKey)
    }

    static func retrievePassword() -> String? {
        return KeychainWrapper.standard.string(forKey: Constants.passwordKey)
    }
    
    
}

enum LogoutResult {
    case success
    case failure(LogoutModel?)
    case networkFailure(NetworkError)
}
