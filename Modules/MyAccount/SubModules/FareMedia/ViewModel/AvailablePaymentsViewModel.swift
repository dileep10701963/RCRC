//
//  AvailablePaymentsViewModel.swift
//  RCRC
//
//  Created by Errol on 03/08/21.
//

import Foundation
import Alamofire

struct AvailablePaymentsViewModel {
    private let service: ServiceManager

    init(service: ServiceManager = .sharedInstance) {
        self.service = service
    }

    func getPaymentMethods(completion: @escaping (Result<PaymentMethods, FareMediaError>) -> Void) {
        let endpoint = EndPoint(baseUrl: .journeyPlanner, methodName: URLs.fareMediaPaymentMethods, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let requestParameters = DefaultParameters()
        let headers = AFCAPIHeaders.generatePublic()

        service.withRequest(endPoint: endpoint, parameters: requestParameters, headers: headers, resultData: PaymentMethods.self) { (result) in
            switch result {
            case let .success(paymentMethods):
                completion(.success(paymentMethods))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
