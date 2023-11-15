//
//  EditProfileViewModel.swift
//  RCRC
//
//  Created by Errol on 26/04/21.
//

import Foundation
import UIKit
import Alamofire

enum ResponseResult: Equatable {
    case success
    case failure(NetworkError, String)
}

enum EditProfileTextFields {
    case name
    case lastName
    case mobile
    case email
}

class EditProfileViewModel: NSObject {

    var countryCodeDigits: Int? = 9
    var name: String? {
        didSet {
            validateName(name, .name)
        }
    }
    
    var mobileNumber: String? {
        didSet {
            validateMobile(mobileNumber)
        }
    }
    
    var email: String? {
        didSet {
            validateEmail(email)
        }
    }
    
    var lastName: String? {
        didSet {
            validateName(lastName, .lastName)
        }
    }
    
    var isValid: TextFieldObservable<String?, EditProfileTextFields?> = TextFieldObservable(nil, nil)
    
    func validateName(_ value: String?, _ type: EditProfileTextFields) {
        if let value = value, value.isNotEmpty {
            isValid.fieldType = type
            isValid.message = nil
        } else {
            isValid.fieldType = type
            isValid.message = type == .name ? Constants.firstNameValidationMessage.localized: Constants.secondNameValidationMessage.localized
        }
    }

    func validateMobile(_ value: String?) {
        if let value = value, value.isNotEmpty {
            
            let plus: Character = "+"
            if !value.contains(plus) {
                
                //if Validation.shared.isValidPhone(phone: value) {
                if countryCodeDigits == nil {
                    if value.count < 6 || value.count > 14 {
                        isValid.fieldType = .mobile
                        isValid.message = Constants.mobileNumberValidationMessage.localized
                    } else {
                        isValid.fieldType = .mobile
                        isValid.message = nil
                    }
                } else if countryCodeDigits == value.count {
                    isValid.fieldType = .mobile
                    isValid.message = nil
                } else {
                    isValid.fieldType = .mobile
                    isValid.message = Constants.mobileNumberValidationMessage.localized
                }
            }
        } else {
            isValid.fieldType = .mobile
            isValid.message = Constants.mobileNumberValidationMessage.localized
        }
    }

    func validateEmail(_ value: String?) {
        if let value = value, value.isNotEmpty {
            if Validation.shared.isValidEmail(email: value) {
                isValid.fieldType = .email
                isValid.message = nil
            } else {
                isValid.fieldType = .email
                isValid.message = "Invalid Email"
            }
        } else {
            isValid.fieldType = .email
            isValid.message = "Email cannot be empty"
        }
    }

    func checkFieldValidation(data: EditProfileModel) -> Bool {
        if Validation.shared.isValidEmail(email: data.mail),
           Validation.shared.isValidPhone(phone: data.phone) {
            return true
        }
        return false
    }
    
    func updateProfileData(endpoint: String = URLs.editCustomerDetail, profileModel: EditProfileModel,completion: @escaping (ResponseResult) -> Void) {
        let requestParam: EditProfileModel = profileModel
        let endPoint = EndPoint(baseUrl: .getProfile, methodName: endpoint, method: .put, encoder: JSONParameterEncoder.default)
        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: requestParam) { result in
            switch result {
            case .success(_):
                completion(.success)
            case let .failure(error):
                completion(.failure(error, Constants.serverErrorAlertMessage))
            }
        }
    }
    
    func getPhoneNumberWithOutExt(phoneCodeModel: PhoneCodeModel?, currentNumber: String) -> (number: String, numbExtension: String) {
        
        var updateMobileNumber: String = currentNumber
        var numberExtension: String = "+966"
        if currentNumber == emptyString || currentNumber == "" {
            return (currentNumber, numberExtension)
        }
        
        if let phoneCodeModel = phoneCodeModel, phoneCodeModel.CountryList.count > 0 {
            let plus: Character = "+"
            if updateMobileNumber.contains(plus) {
                let contactNum = updateMobileNumber.replacingOccurrences(of: "+", with: "")
                updateMobileNumber = contactNum
            }
            
            let isoCode = phoneCodeModel.CountryList.map({$0.code ?? ""})
            var filterISOCode = isoCode
            for (index, firstC) in updateMobileNumber.enumerated() {
                filterISOCode = filterISOCode.filter({ item in
                    if item.count > index {
                        let characterIndex = item.index(item.startIndex, offsetBy: index)
                        return item[characterIndex] == firstC
                    } else {
                        return false
                    }
                })
                if filterISOCode.count == 1 && filterISOCode.isEmpty == false {
                    numberExtension = filterISOCode[0].contains(plus) ? filterISOCode[0]: "+\(filterISOCode[0])"
                    break
                }
            }
            if filterISOCode.count > 0 {
                updateMobileNumber = String(updateMobileNumber.dropFirst(filterISOCode[0].count))
            }
        }
        
        return (updateMobileNumber, numberExtension)
    }
    
    func getValidationCountryCodeDigit(countryLabel: String, countryCodeModels: [CountryListModel]) -> Int {
        var countryCodeLabel: String = countryLabel
        var validationCode = 9
        if countryLabel != emptyString {
            let plus: Character = "+"
            if countryCodeLabel.contains(plus) {
                let contactNum = countryCodeLabel.replacingOccurrences(of: "+", with: "")
                countryCodeLabel = contactNum
            }
        }
        
        if let index = countryCodeModels.firstIndex(where: {$0.code ?? "" == countryCodeLabel}) {
            validationCode = countryCodeModels[index].digit ?? 9
        }
        
        return validationCode
    }
    
}
