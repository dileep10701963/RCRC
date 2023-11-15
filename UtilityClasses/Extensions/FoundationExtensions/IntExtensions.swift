//
//  IntExtensions.swift
//  RCRC
//
//  Created by Errol on 05/03/21.
//

import Foundation

extension Int {

    var minutes: Int {
        return self / 60
    }
    
    var walkingDistance: String {
        var walkingDistance: String = emptyString
        if self == 0 {
            return walkingDistance
        }
        let distance = Double(self)/1000.0
        if distance < 1 {
            walkingDistance = "\(Constants.footPathTitle.localized.capitalized): \(self) m, "
        } else {
            let distanceTwoDecimal = Double(String(format: "%.2f", distance))
            walkingDistance = "\(Constants.footPathTitle.localized.capitalized): \(String(format: "%g", distanceTwoDecimal!)) km, "
        }
        
        return walkingDistance
        
    }
    
    var walkingDistanceForLabel: String {
        if self == 0 {
            return emptyString
        }
        let distance = Double(self)/1000.0
        if distance < 1 {
            return "\(self) m"
        } else {
            let distanceTwoDecimal = Double(String(format: "%.2f", distance))
            return "\(String(format: "%g", distanceTwoDecimal!)) km"
        }
    }
}
