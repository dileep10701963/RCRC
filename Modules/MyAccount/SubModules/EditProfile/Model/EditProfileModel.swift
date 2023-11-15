//
//  EditProfileModel.swift
//  RCRC
//
//  Created by Aashish Singh on 19/07/22.
//

import Foundation

struct EditProfileModel: Encodable {
    var name: String
    var surname: String
    var gender: String
    var documentType: String
    var personalId: String
    var mail: String
    var dateOfBirth: String
    var phone: String
    var additionalEmails: [AdditionalEmail]
    var additionalPhones: [AdditionalPhone]
}

// MARK: - AdditionalEmail
struct AdditionalEmail: Encodable {
    let email: String
}

// MARK: - AdditionalPhone
struct AdditionalPhone: Encodable {
    let phoneNumber: String
}
