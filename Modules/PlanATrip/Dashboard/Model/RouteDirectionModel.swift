//
//  RouteDirectionModel.swift
//  RCRC
//
//  Created by Aashish Singh on 02/07/23.
//

import Foundation

enum SelectedDirection {
    case north, south, none
}

struct RouteDirectionModel {
    
    var northDirection: String
    var southDirection: String
    var directionType: SelectedDirection
    var northID: String = ""
    var southID: String = ""
    
}
