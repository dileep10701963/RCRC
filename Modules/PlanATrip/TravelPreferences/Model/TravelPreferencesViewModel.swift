//
//  TravelPreferencesViewModel.swift
//  RCRC
//
//  Created by Aashish Singh on 03/08/22.
//

import Foundation
import Alamofire

class TravelPreferencesViewModel: NSObject {
    
    var travelPreferencesResult: Observable<TravelPreferenceModel?, Error?> = Observable(nil, nil)
    private let service: ServiceManager
    
    init(service: ServiceManager = ServiceManager.sharedInstance) {
        self.service = service
    }
    
    func fetchTravelPreferencesResult(endpoint: String = URLs.travelPreferences, input: String = UserDefaultService.getUserName(), completionHandler : (() -> Void)? = nil) {
        if let completionHandler = completionHandler {
            completionHandler()
        }
    }
    
    private func setDefaultValue() {
        self.travelPreferencesResult.value = TravelPreferenceModel(userName: UserDefaultService.getUserName(), alternativeStopsPreference: true, busTransport: true, careemTransport: false, impaired: nil, maxTime: .fifteenMin, metroTransport: false, routePreference: .quickest, uberTransport: false, walkSpeed: .normal)
    }
    
    func saveTravelPreferences(endpoint: String = URLs.travelPreferences, preferenceModel: TravelPreferenceModel, completion : @escaping(ResponseResult) -> Void) {
        
        let endPoint = EndPoint(baseUrl: .saveTravelPreference, methodName: endpoint, method: .post, encoder: JSONParameterEncoder.default)

        let travelPreferenceModel = TravelPreferenceModel(userName: preferenceModel.userName, alternativeStopsPreference: preferenceModel.alternativeStopsPreference, busTransport: preferenceModel.busTransport, careemTransport: preferenceModel.careemTransport, impaired: preferenceModel.impaired, maxTime: preferenceModel.maxTime, metroTransport: preferenceModel.metroTransport, routePreference: preferenceModel.routePreference, uberTransport: preferenceModel.uberTransport, walkSpeed: preferenceModel.walkSpeed)

        let savePreferenceModel = SaveTravelPreferencesModel(collection: "travelpreferences", documents: [travelPreferenceModel])

        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: savePreferenceModel, resultData: LoginResponseModel.self) { result in
            switch result {
            case .success:
                completion(.success)
            case let .failure(error):
                if error == .invalidToken {
                    completion(.failure(.invalidToken, Constants.operationFailedMessage))
                } else {
                    completion(.failure(.invalidData, Constants.operationFailedMessage))
                }
            }
        }
    }

}
