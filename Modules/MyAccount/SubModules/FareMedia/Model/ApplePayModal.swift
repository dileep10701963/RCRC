//
//  ApplePayModal.swift
//  RCRC
//
//  Created by Aashish Singh on 16/11/22.
//


import Foundation
import PassKit

struct ApplePayModal {
    
    var paymentStatus: PKPaymentAuthorizationStatus
    //var errors: [Error]?
    var error: Error?
    var token: PKPaymentToken?
    var transactionIdentifier: String?
    var paymentData: String?
}

