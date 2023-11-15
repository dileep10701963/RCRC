//
//  SignUpModel.swift
//  RCRC
//
//  Created by Aashish Singh on 08/07/22.
//

import Foundation

struct SignUpModel: Encodable {
    var dateOfBirth: String?
    var documentType: String?
    var elegibleConcession: String?
    var gender: String?
    var mail: String?
    var name: String?
    var password: String?
    var personalId: String?
    var phone: String?
    var reseller: String?
    var surname: String?
    var user: String?
}

let gender = [IncidentLostFoundData(category: "Gender", subCategory: ["Male", "Female"])]

struct PhoneCodeModel: Decodable {
    var CountryList: [CountryListModel]
}

struct CountryListModel: Decodable {
    var country: String?
    var code: String?
    var iso: String?
    var digit: Int?
}
    
