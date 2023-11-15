//
//  CDFAQ+Extension.swift
//  RCRC
//
//  Created by Admin on 14/08/20.
//

import Foundation

extension CoreDataFAQ {
    func convertToFAQResponse() -> FAQResponse {

        return FAQResponse(question: self.question, answer: self.answer)

    }
}
