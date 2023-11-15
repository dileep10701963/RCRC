//
//  ErrorModel.swift
//  RCRC
//
//  Created by Aashish Singh on 08/07/22.
//

import Foundation

struct ErrorResponseModel: Decodable {
    var error: Bool?
    var message: String?
}
