//
//  Validation.swift
//  RCRC
//
//  Created by Admin on 22/03/21.
//

import UIKit

class Validation: NSObject {

    static let shared = Validation()

    func isValidPhone(phone: String) -> Bool {
        var isValid: Bool = false
        let range = NSRange(location: 0, length: phone.count)
        do {
            // OLD Regex For Number Syntax -> +966 123-345-4563
            //let regex = try NSRegularExpression(pattern: "^\\+966\\s[0-9]{3}-[0-9]{3}-[0-9]{3,4}$")
            
            let regex = try NSRegularExpression(pattern: "^\\+966\\s?[0-9]{9,9}$")
            if regex.firstMatch(in: phone, options: [], range: range) != nil {
                isValid = true
            }
        } catch {
            print(error.localizedDescription)
        }
        return isValid
//        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
//        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
//        return phoneTest.evaluate(with: phone)
    }

    func isValidEmail(email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }

    func isValidPassword(password: String) -> Bool {
        let passwordRegex = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&]).{4,}$")
        return passwordRegex.evaluate(with: password)
    }

    func checkEmptyField(field: String) -> Bool {
        if field.isEmpty {
            return false
        }
        return true
    }
}
