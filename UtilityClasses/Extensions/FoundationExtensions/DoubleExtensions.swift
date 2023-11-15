//
//  DoubleExtensions.swift
//  RCRC
//
//  Created by Errol on 10/11/20.
//

import Foundation

extension Double {

    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }

    func toInt() -> Int {
        if self >= Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        }
        return 0
    }
}
