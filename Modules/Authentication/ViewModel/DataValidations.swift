//
//  DataValidations.swift
//  RCRC
//
//  Created by Errol on 15/01/21.
//

import Foundation

enum DataType {
    case email
    case password
    case name
    case mobileNumber
}

class DataValidations: NSObject {

    static let shared = DataValidations()

    // (todo)
    func performValidation(for: DataType, text: String?) -> Bool {
        switch `for` {
        case .email:
            break
        case .mobileNumber:
            break
        case .name:
            break
        case .password:
            break
        }
        return true
    }
}
