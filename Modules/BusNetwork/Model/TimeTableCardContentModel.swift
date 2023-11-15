//
//  TimeTableCardContentModel.swift
//  RCRC
//
//  Created by Aashish Singh on 04/11/22.
//

import Foundation

// MARK: - TimeTableCardContentModel
struct TimeTableCardContentModel {
    let originStartEngName: String
    let originStartArbName: String
    let originStopID: String
    
    let desStartEngName: String
    let desStartArbName: String
    let desStopID: String
    
    let firstBusTime: String
    let lastBusTime: String
    let frequency: String
    
    let originStopNameLabel: String
    let originStopIDLabel: String
    let desStopNameLabel: String
    let desStopIDLabel: String
    let firstBusTimeLabel: String
    let lastBusTimeLabel: String
    let frequencyLabel: String
    
}

// MARK: Nested Content Field Key Name
enum NestedContentFieldKeyName: String {
    case originStopNameEnglish = "OriginStopNameEnglish"
    case originStopNameArabic = "OriginStopNameArabic"
    case originStopId = "BusStopId"
    case destinationStopNameEnglish = "DestinationStopNameEnglish"
    case destinationStopNameArabic = "DestinationStopNameArabic"
    case destinationStopID = "BusStopId1"
    case firstBusTime = "FirstBusTime"
    case lastBusTime = "LastBusTime"
    case frequencyInMinutes = "FrequencyInMinutes"
}
