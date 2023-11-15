//
//  FareMediaBarcodes.swift
//  RCRC
//
//  Created by Saheba Juneja on 11/05/23.
//

import Foundation

struct ETicket: Codable {
    let items: [BarcodeTicket]?
}

struct BarcodeTicket: Codable {
    let order: Int?
    let rawBytes: String?
}
