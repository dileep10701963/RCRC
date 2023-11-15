//
//  FareMediaError.swift
//  RCRC
//
//  Created by Errol on 03/08/21.
//

import Foundation

enum FareMediaError: Error {
    case notLoggedIn
    case invalidToken
    case connectivity
    case invalidData
}
