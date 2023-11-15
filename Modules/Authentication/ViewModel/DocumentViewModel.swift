//
//  DocumentViewModel.swift
//  RCRC
//
//  Created by Aashish Singh on 13/07/22.
//

import UIKit
import Alamofire
import GoogleMaps

class DocumentViewModel: NSObject {

    var documentResult: Observable<DocumentTypeResponseModel?, Error?> = Observable(nil, nil)
    var favoritePlaces = ValueObservable<[SavedLocation]>([])

    func getDocumentTypes(endpoint: String = URLs.documentTypes, completionHandler : (() -> Void)? = nil) {
        let request = DocumentTypeRequest()
        let endPoint = EndPoint(baseUrl: .documentTypes, methodName: endpoint, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: request, res: DocumentTypeResponseModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(documentResult):
                self.documentResult.value = documentResult
            case let .failure(error):
                self.documentResult.error = error
            }
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
    }
}
