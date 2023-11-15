//
//  FrequentlyAskedQuestionViewModel.swift
//  RCRC
//
//  Created by anand madhav on 12/08/20.
//

import Foundation
import Alamofire
class FrequentlyAskedQuestionViewModel: NSObject {

    override init() {
        super.init()
    }

    var faqResult: Observable<FAQModel?, Error?> = Observable(nil, nil)

    func numberOfSection() -> Int? {
        if let items = self.faqResult.value?.items, items.count > 0, let contenFields = items[0].contentFields, contenFields.count > 0 {
            return contenFields[0].nestedContentFields?.count
        } else {
            return 0
        }
    }

    func setQuestionText(indexPath: IndexPath) -> String? {
        
        if let items = self.faqResult.value?.items, items.count > 0, let contenFields = items[0].contentFields, contenFields.count > 0 {
            return contenFields[0].nestedContentFields?[indexPath.section].contentFieldValue?.data
        } else {
            return emptyString
        }
    }

    func setAnswerText(indexPath: IndexPath) -> (answer: String?, link: String) {
        if let items = self.faqResult.value?.items, items.count > 0, let contenFields = items[0].contentFields, contenFields.count > 0 {
            if let childNestedField = contenFields[0].nestedContentFields?[indexPath.section].nestedContentFields, childNestedField.count > 0 {
                let answer = childNestedField.first(where: {$0.name?.lowercased() == "answer".lowercased()})?.contentFieldValue?.data
                let linkText = childNestedField.first(where: {$0.name?.lowercased() == "LinkText".lowercased()})?.contentFieldValue?.data ?? emptyString
                return (answer, linkText)
            } else {
                return (emptyString, emptyString)
            }
        } else {
            return (emptyString, emptyString)
        }
    }

    func getFAQ(completionHandler : (() -> Void)? = nil) {

        let endPoint = EndPoint(baseUrl: .frequentlyAskedQuestions, methodName: URLs.faqEndPoints, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        struct DefaultParam: Encodable {}
        let param = DefaultParam()
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, params: param, res: FAQModel.self) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(faq):
                self.faqResult.value = faq
            case let .failure(error):
                self.faqResult.error = error
            }
            if let completionHandler = completionHandler { completionHandler() }
        }
    }
}
