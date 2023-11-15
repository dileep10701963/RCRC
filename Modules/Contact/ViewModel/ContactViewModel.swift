//
//  ContactViewModel.swift
//  RCRC
//
//  Created by Errol on 06/04/21.
//

import Foundation
import Alamofire

class ContactViewModel: NSObject {

    var contactDetails: Observable<ContactModel?, Error?> = Observable(nil, nil)

    func fetchContactDetails(completionHandler : (() -> Void)? = nil) {
        let endPoint = EndPoint(baseUrl: .contact, methodName: URLs.contactEndpoint, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        struct DefaultParam: Encodable {}
        let param = DefaultParam()
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: param, res: ContactModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(contactInformation):
                self.contactDetails.value = contactInformation
            case let .failure(error):
                self.contactDetails.error = error
            }
            if let completion = completionHandler { completion() }
        }
    }
}
