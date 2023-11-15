//
//  SignUpViewModel.swift
//  RCRC
//
//  Created by Errol on 15/01/21.
//

import Foundation
import UIKit
import Alamofire

enum RegistrationTextFields {
    case name
    case lastName
    case mobile
    case email
    case confirmEmail
    case password
    case repeatPassword
    case citizenshipID
    case dateOfBirth
    case gender
    case consession
    case reseller
    case documentType
    case userID
    case confirmMobile
}

class SignUpViewModel: NSObject {
    var phoneCodeModel = PhoneCodeModel(CountryList: [CountryListModel]())
    var countryCodeDigits: Int? = 9
    var selectedCountryListModel: CountryListModel?
    
    var email: String? {
        didSet {
            validateEmail(email)
        }
    }
    
    var confirmEmail: String? {
        didSet {
            validateFields(value: confirmEmail, fieldType: .confirmEmail, message: Constants.confirmEmailValidationMessage.localized)
        }
    }
    
    var password: String? {
        didSet {
            //validatePasswords(password, repeatPassword)
            validateFields(value: password, fieldType: .password, message: Constants.passwordValidationMessage.localized)
        }
    }
    var repeatPassword: String? {
        didSet {
            validateFields(value: repeatPassword, fieldType: .repeatPassword, message: Constants.repeatPasswordValidationMessage.localized)
        }
    }
    var name: String? {
        didSet {
            validateFields(value: name, fieldType: .name, message: Constants.firstNameValidationMessage.localized)
        }
    }
    
    var countryCode: String?
    
    var mobileNumber: String? {
        didSet {
            validateMobile(mobileNumber)
        }
    }
    
    var confirmMobileNumber: String? {
        didSet {
            validateConfirmMobile(confirmMobileNumber)
        }
    }
    
    var dateOfBirth: String? {
        didSet {
            validateFields(value: dateOfBirth, fieldType: .dateOfBirth, message: Constants.notEmptyValidationMessage)
        }
    }
    
    var citizenshipID: String? {
        didSet {
            validateFields(value: citizenshipID, fieldType: .citizenshipID, message: Constants.citizenshipValidationMessage)
        }
    }
    
    var gender: String? {
        didSet {
            validateFields(value: gender, fieldType: .gender, message: Constants.notEmptyValidationMessage)
        }
    }
    
    var lastName: String? {
        didSet {
            validateFields(value: lastName, fieldType: .lastName, message: Constants.secondNameValidationMessage.localized)
        }
    }
    
    var documentType: String? {
        didSet {
            validateFields(value: documentType, fieldType: .documentType, message: Constants.notEmptyValidationMessage)
        }
    }
    
    var userID: String? {
        didSet {
            validateFields(value: userID, fieldType: .userID, message: Constants.userIdValidationMessage.localized)
        }
    }
    
    var isConcession: Int = -1 {
        didSet {
            validateButton(selectedValue: isConcession, fieldType: .consession)
        }
    }
    
    var isReseller: Int = -1 {
        didSet {
            validateButton(selectedValue: isReseller, fieldType: .reseller)
        }
    }

    var isValid: TextFieldObservable<String?, RegistrationTextFields?> = TextFieldObservable(nil, nil)
    
    func validateConfirmMobile(_ value: String?){
        if let value = value, value.isNotEmpty {
            
            let plus: Character = "+"
            if !value.contains(plus) {
                
                //if Validation.shared.isValidPhone(phone: value) {
                if countryCodeDigits == nil {
                    if value.count < 6 || value.count > 14 {
                        isValid.fieldType = .mobile
                        isValid.message = Constants.confirmNumberValidationMessage.localized
                    } else {
                        isValid.fieldType = .mobile
                        isValid.message = nil
                    }
                } else if countryCodeDigits == value.count {
                    isValid.fieldType = .mobile
                    isValid.message = nil
                } else {
                    isValid.fieldType = .mobile
                    isValid.message = Constants.confirmNumberValidationMessage.localized
                }
            }
        } else {
            isValid.fieldType = .mobile
            isValid.message = Constants.mobileNumberValidationMessage.localized
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
                    isValid.message = Constants.emailValidationMessage.localized
                }
            } else {
                isValid.fieldType = .email
                isValid.message = Constants.emailValidationMessage.localized
            }
    }

    /*func validatePasswords(_ password: String?, _ repeatPassword: String?) {

        if let password = password, password.isNotEmpty, password.count >= 8 && password.count <= 32 {
            isValid.fieldType = .password
            isValid.message = nil
            if let repeatPassword = repeatPassword, repeatPassword.isNotEmpty {
                if password == repeatPassword {
                    if Validation.shared.isValidPassword(password: password) {
                        isValid.fieldType = .password
                        isValid.message = nil
                        isValid.fieldType = .repeatPassword
                        isValid.message = nil
                    } else {
                        isValid.fieldType = .password
                        isValid.message = "Please enter a strong password"
                    }
                } else {
                    isValid.fieldType = .password
                    isValid.message = "Entered password does not match with the password field"
                    isValid.fieldType = .repeatPassword
                    isValid.message = nil
                }
            } else if let repeatPassword = repeatPassword, repeatPassword.isEmpty {
                isValid.fieldType = .repeatPassword
                isValid.message = "Entered password does not match with the password field"
            }
        } else if let password = password, password.isEmpty {
            isValid.fieldType = .password
            isValid.message = "The password must be between 8-32 characters, contains (uppercase, lowercase, special character and numbers), different from the current password and must not match with the last three passwords"
        }
    }*/
    
    func validateFields(value: String?, fieldType: RegistrationTextFields, message: String) {
        switch fieldType {
        case .password:
            if let password = password, password.isNotEmpty, password.count >= 8 && password.count <= 32, password.isValidateSecialPassword {
                isValid.fieldType = .password
                isValid.message = nil
                if password == repeatPassword {
                    isValid.fieldType = .repeatPassword
                    isValid.message = nil
                } else {
                    if let repeatPassword = repeatPassword , !repeatPassword.isEmpty {
                        isValid.fieldType = .repeatPassword
                        isValid.message = Constants.repeatPasswordValidationMessage
                    }
                }
            } else {
                isValid.fieldType = .password
                isValid.message = message
            }
        case .repeatPassword:
            if password == repeatPassword {
                isValid.fieldType = .repeatPassword
                isValid.message = nil
            } else {
                isValid.fieldType = .repeatPassword
                isValid.message = message
            }
        case .userID:
            if let value = value, value.isNotEmpty, value.isSmallAlphanumeric, value.count >= 5 && value.count <= 45 {
                isValid.fieldType = .userID
                isValid.message = nil
            } else {
                isValid.fieldType = .userID
                isValid.message = message
            }
        default:
            
            if let value = value, value.isNotEmpty {
                isValid.fieldType = fieldType
                isValid.message = nil
            } else {
                isValid.fieldType = fieldType
                isValid.message = message
            }
        }
    }
    
    func validateButton(selectedValue: Int, fieldType: RegistrationTextFields) {
        if selectedValue != -1 {
            isValid.fieldType = fieldType
            isValid.message = nil
        } else {
            isValid.fieldType = fieldType
            isValid.message = "Please select the value"
        }
    }
    
    func register(name: String, mobile: String, email: String, password: String) -> Bool {

        let userData = ProfileInformation(emailAddress: email, mobileNumber: mobile, fullName: name, image: nil)
        UserProfileDataRepository.shared.create(record: userData)
        if KeychainWrapper.standard.set(password, forKey: "password") {
            return true
        } else {
            return false
        }
    }

    func checkForEmptyFields() -> Bool {
        if let email = self.email, email.isNotEmpty,
           let password = self.password, password.isNotEmpty,
           let confirmPassword = self.repeatPassword, confirmPassword.isNotEmpty,
           let name = self.name, name.isNotEmpty,
           let mobileNumber = self.mobileNumber, mobileNumber.isNotEmpty {
            return false
        }
        return true
    }

    func checkFieldValidation() -> Bool {
        if Validation.shared.isValidEmail(email: self.email ?? emptyString),
           Validation.shared.isValidPhone(phone: self.mobileNumber ?? emptyString),
           Validation.shared.isValidPassword(password: self.password ?? emptyString) {
            return true
        }
        return false
    }

    func checkIfPasswordsMatch() -> Bool {
        if password == repeatPassword {
            return true
        }
        return false
    }
    
    func registerUser(signUpModel: SignUpViewModel, completion: @escaping(LoginResult) -> Void) {
        
        let dob = signUpModel.dateOfBirth ?? emptyString
        let documentType = signUpModel.documentType ?? emptyString
        let elegibleConcession = "false"//signUpModel.isConcession == 1 ? "true": "false"
        let gender = signUpModel.gender?.uppercased() ?? emptyString
        let mail = signUpModel.email ?? emptyString
        let name = signUpModel.name ?? emptyString
        let password = signUpModel.password ?? emptyString
        let personalId = signUpModel.citizenshipID ?? emptyString
        let reseller = "false"//signUpModel.isReseller == 1 ? "true": "false"
        let surname = signUpModel.lastName ?? emptyString
        let user = signUpModel.userID ?? emptyString
        var phone = ""
        if currentLanguage == .arabic || currentLanguage == .urdu {
            phone = "\(signUpModel.mobileNumber ?? emptyString)\(signUpModel.countryCode ?? emptyString)".replacingOccurrences(of: " ", with: "")
        } else {
            phone = "\(signUpModel.countryCode ?? emptyString)\(signUpModel.mobileNumber ?? emptyString)".replacingOccurrences(of: " ", with: "")
        }
        let signUpModel = SignUpModel(dateOfBirth: dob, documentType: documentType, elegibleConcession: elegibleConcession, gender: gender, mail: mail, name: name, password: password, personalId: personalId, phone: phone, reseller: reseller, surname: surname, user: user)
        AuthenticationService.signUp(signUpModel: signUpModel, completion: completion)
    }
    
    func getPhoneCode(endpoint: String = URLs.phoneCode, completionHandler : @escaping (PhoneCodeModel?, NetworkError?) -> Void) {
        let endPoint = EndPoint(baseUrl: .journeyPlanner, methodName: endpoint, method: .get, encoder: URLEncodedFormParameterEncoder.default)
        let parameters = DefaultParameters()

        ServiceManager.sharedInstance.withRequest(endPoint: endPoint, parameters: parameters, resultData: PhoneCodeModel.self) { result in
            switch result {
            case .success((let data, _)):
                let phoneCodeModel = data
                completionHandler(phoneCodeModel, .caseIgnore)
            case .failure(let errr):
                completionHandler(nil, errr)
            }
        }
    }
    
    func getCountryAndISOCodeFromModel(_ row: Int) -> String {
        return "\(phoneCodeModel.CountryList[row].iso ?? "") +\(phoneCodeModel.CountryList[row].code ?? "")"
    }
    
    func getCountryCodeJsonFromBundle() -> PhoneCodeModel? {
        if let path = Bundle.main.path(forResource: "CountryCode", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path))
                let jsonResult = try JSONDecoder().decode(PhoneCodeModel.self, from: data)
                return jsonResult as PhoneCodeModel
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
        } else {
            return nil
        }
    }
    
    func getCountryCodeFromModel(_ row: Int) -> String {
        var countryCode = "+\(phoneCodeModel.CountryList[row].code ?? "")"
        
        if currentLanguage == .arabic || currentLanguage == .urdu {
            //let reversedCountryCode = String(countryCode.reversed())
            countryCode = String(countryCode.reversed())
        }
        self.countryCode = countryCode
        return countryCode
    }
}

extension String {

    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}

