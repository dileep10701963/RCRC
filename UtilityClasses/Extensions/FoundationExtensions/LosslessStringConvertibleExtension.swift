//
//  LossLessStringConvertibleExtension.swift
//  RCRC
//
//  Created by Errol on 28/10/20.
//

import Foundation

// MARK: - LosslessStringConvertible Extensions
extension LosslessStringConvertible {
    // Double/Int to String Conversion
    var string: String { .init(self) }
}
