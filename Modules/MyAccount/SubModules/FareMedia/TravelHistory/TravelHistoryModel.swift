//
//  TravelHistoryModel.swift
//  RCRC
//
//  Created by Saheba Juneja on 03/05/23.
//

import Foundation

// MARK: - TravelHistory
struct TravelHistory: Codable {
    var items: [HistoryItem]?
    var message: String?
}

// MARK: - Item
struct HistoryItem: Codable {
    var date: String? = "2021-02-28"
    var agency: String?
    var logSerialNumber: String?
    var zone: String?
    var line: String? = "Line 1 metro 2"
    var station: String? = "2Y2 Line2 P2"
    var vehicle: String?
    var recordInDate: Date?
}
