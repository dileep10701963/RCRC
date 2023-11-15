//
//  ReportLostViewModel.swift
//  RCRC
//
//  Created by Admin on 20/11/20.
//

import UIKit

class ReportLostViewModel: NSObject {
     var dateOfIncidence: String = ""
     var issue: String = ""
     var name: String = ""
     var email: String = ""
     var contactNumber: String = ""
     var itemCategory: String = ""
     var placeOfIncidence: String = ""
     var itemDetail: String = ""
     var showError: Observable<String?, Error?>? = Observable(nil, nil)

    func validateReport() -> Bool {
        var result = true
        if dateOfIncidence == "" {
            showError?.value = Constants.dateOfIncidenceMissing
            result = false
        }
        if issue == "" {
            showError?.value = Constants.issueMissing
            result = false
        }
        if name == "" {
            showError?.value = Constants.nameMissing
            result = false
        }
        if email == "" {
            showError?.value = Constants.emailMissing
            result = false
        }
        if !isEmailValid() {
            showError?.value = Constants.emailValidationError
            result = false
        }
        if contactNumber == "" {
            showError?.value = Constants.contactMissing
            result = false
        }
        if itemCategory == "" {
            showError?.value = Constants.categoryMissing
            result = false
        }
        if placeOfIncidence == "" {
            showError?.value = Constants.placeofIncidenceMissing
            result = false
        }
        return result
    }

    func isEmailValid() -> Bool {
        return Validation.shared.isValidEmail(email: email )
    }

}
