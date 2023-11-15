//
//  WeatherModel.swift
//  RCRC
//
//  Created by Errol on 04/08/20.
//

import Foundation

struct WeatherModel: Decodable {

  var temperature: Double?
  var color, textColor, weatherIcon, weather, description: String?
}
