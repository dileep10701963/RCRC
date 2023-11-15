//
//  StopsModel.swift
//  RCRC
//
//  Created by Aashish Singh on 07/06/23.
//

import Foundation

struct StopsModel: Decodable {
    var items: [StopsItem]?
}

struct StopsItem: Decodable {
    var table_name: String?
    var field_name: String?
    var language: String?
    var record_id: Int?
    var translation: String?
    var stop_lat: String?
    var stop_lon: String?
}
