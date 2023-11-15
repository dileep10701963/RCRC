//
//  LangaugeSelectionViewModel.swift
//  RCRC
//
//  Created by Aashish Singh on 17/02/23.
//

import Foundation
import Alamofire

// Term And Conditions Request Paremeters
struct TermsCondition: Encodable {
}

class LangaugeSelectionViewModel: NSObject {

    var languageSelectionResult: Observable<LanguageSelectionModel?, Error?> = Observable(nil, nil)
    private let service: ServiceManager
    
    init(service: ServiceManager = ServiceManager.sharedInstance) {
        self.service = service
    }
    
    func getTermsAndConditions(endpoint: String = URLs.termsAndConditions, completionHandler : (() -> Void)? = nil) {

        let endPoint = EndPoint(baseUrl: .termAndConditions, methodName: endpoint, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let requestParam = TermsCondition()
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: requestParam, resultData: LanguageSelectionModel.self) { result in
            switch result {
            case let .success((data, _)):
                if let data = data {
                    self.languageSelectionResult.value = data
                }
            case .failure(_):
                break
            }
            if let completionHandler = completionHandler {
                completionHandler()
            }
        }
    }
    
    func getAttributedString(model: LanguageSelectionModel) -> (title: String, content: NSMutableAttributedString?) {
        if let items = model.items, items.count > 0, let contentField = items[0].contentFields, contentField.count > 0 {
            
            var titleValue: String = emptyString
            var contentAttr: NSMutableAttributedString? = NSMutableAttributedString(string: emptyString)
            
            if let content = contentField.first(where: {$0.label?.lowercased() == "HTML".lowercased()}), let data = content.contentFieldValue?.data {
                contentAttr = data.htmlToAttributedString(font: Fonts.CodecRegular.fourteen, color: Colors.textColor)
            }
            
            if let title = contentField.first(where: {$0.label?.lowercased() == "Title".lowercased()}), let data = title.contentFieldValue?.data {
                titleValue = data 
            }
            
            return (titleValue, contentAttr)
        } else {
            return (emptyString, nil)
        }
    }
    
    func isArabicContentWithData(model: LanguageSelectionModel) -> (isStringEmpty: Bool, isArabic: Bool) {
        if let items = model.items, items.count > 0, let contentField = items[0].contentFields, contentField.count > 0 , let contentFieldValue = contentField[0].contentFieldValue, let data = contentFieldValue.data {
            return (false, data.isArabic)
        } else {
            return (true, false)
        }
    }
    
}
