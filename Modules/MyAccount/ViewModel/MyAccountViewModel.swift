//
//  MyAccountViewModel.swift
//  RCRC
//
//  Created by Errol on 26/04/21.
//

import Foundation
import Alamofire

enum NetworkResult: Equatable {
    case success
    case failure(NetworkError)
}

class MyAccountViewModel: NSObject {

    var myAccountData: ValueObservable<MyAccountDataModel?> = ValueObservable(nil)
    var profileDetailsResult: Observable<ProfileModel?, Error?> = Observable(nil, nil)
    private let service: ServiceManager
    
    init(service: ServiceManager = ServiceManager.sharedInstance) {
        self.service = service
    }

    func fetchData() {
        if let records = UserProfileDataRepository.shared.fetchAll(), let record = records.first {
            let image = Utilities.getProfileImage(record.image)
            let data = MyAccountDataModel(fullName: record.fullName, mobileNumber: record.mobileNumber, emailAddress: record.emailAddress, image: image)
            myAccountData.value = data
        } else {
            myAccountData.value = nil
        }
    }
        
    func fetchProfileDetails(endpoint: String = URLs.getCustomerDetail, completionHandler : (() -> Void)? = nil) {
        let requestParam = GetProfileRequest()
        let endPoint = EndPoint(baseUrl: .getProfile, methodName: endpoint, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: requestParam, resultData: ProfileModel.self) { result in
            switch result {
            case let .success((data, _)):
                self.profileDetailsResult.value = data
            case let .failure(error):
                self.profileDetailsResult.error = error
            }
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
    }
    
    func deleteAccount(completion : @escaping (NetworkResult) -> Void) {
        let endpoint = EndPoint(baseUrl: .delete, methodName: URLs.deleteAccount, method: .delete, encoder: URLEncodedFormParameterEncoder.default)
        let requestParameters = DefaultParameters()
        ServiceManager.sharedInstance.withRequest(endPoint: endpoint, parameters: requestParameters, resultData: LoginResponseModel.self) { result in
            switch result {
            case let .success((_, response)):
                let isStatusCode204 = response.statusCode == 204
                if isStatusCode204 {
                    completion(.success)
                } else {
                    completion(.failure(.invalidData))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
