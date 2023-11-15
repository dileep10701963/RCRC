//
//  MyAccountModel.swift
//  RCRC
//
//  Created by Errol on 17/11/20.
//

import UIKit

struct MyAccountModel {
    var image: UIImage?
    var option: String
}

struct MyAccountDataModel {
    var fullName: String?
    var mobileNumber: String?
    var emailAddress: String?
    var image: UIImage
}

struct ProfileModel: Decodable {
    var name: String?
    var surname: String?
    var gender: String?
    var documentType: String?
    var personalId: String?
    var mail: String?
    var dateOfBirth: String?
    var phone: String?
}
