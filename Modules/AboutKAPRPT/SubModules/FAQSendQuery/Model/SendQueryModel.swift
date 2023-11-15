//
//  SendQueryModel.swift
//  RCRC
//
//  Created by Errol on 09/04/21.
//

import Foundation

struct UserMessage: Codable {
    var time: String?
    var message: String?
}

struct ServerMessage: Codable {
    var time: String?
    var message: String?
}
