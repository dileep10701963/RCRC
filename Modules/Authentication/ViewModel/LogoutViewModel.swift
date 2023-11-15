//
//  LogoutViewModel.swift
//  RCRC
//
//  Created by Errol on 28/06/21.
//

import Foundation
import Alamofire

struct LogoutModel: Decodable {
    let code: String?
    let message: String?
    let timestamp: Date?
    var statusCode: Int?
}

struct LogoutViewModel {

    enum AuthenticationError: Error {
        case logoutFailed(LogoutModel?)
        case networkError(Error)
    }

    let service: ServiceManager

    init(service: ServiceManager = .sharedInstance) {
        self.service = service
    }

    func logout(completion: @escaping(Bool) -> Void) {
        performLogoutRequest { didFailWithError in
            guard let error = didFailWithError else {
                completion(true)
                return
            }
            print(error)
            completion(false)
        }
    }

    private func performLogoutRequest(completion: @escaping (AuthenticationError?) -> Void) {
        let endpoint = EndPoint(baseUrl: .logout, methodName: URLs.logoutEndpoint, method: .post, encoder: URLEncodedFormParameterEncoder.default)
        struct DefaultParameters: Encodable {}
        let parameters = DefaultParameters()
        service.withRequest(endPoint: endpoint, parameters: parameters, resultData: LogoutModel.self) { result in
            switch result {
            case let .success((data, response)):
                let logoutSuccess = response.statusCode == 200
                logoutSuccess ? completion(.none) : completion(.logoutFailed(data))
                if logoutSuccess {
                    ServiceManager.sharedInstance.profileModel = nil
                    UserProfileDataRepository.shared.delete()
//                    KeychainWrapper.standard.removeAllKeys()
                }
            case let .failure(error):
                completion(.networkError(error))
            }
        }
    }
}

enum AuthenticationError: Error {
    case tokenNotAvailable
}

struct LoginService {
    static var loginToken: String {
        if let token = KeychainWrapper.standard.string(forKey: "UserLoginToken") {
            return token
        }
        return ""
    }
}
