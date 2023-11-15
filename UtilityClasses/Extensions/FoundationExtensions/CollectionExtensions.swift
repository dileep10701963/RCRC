//
//  CollectionExtensions.swift
//  RCRC
//
//  Created by Errol on 05/03/21.
//

import Foundation

extension Collection where Indices.Iterator.Element == Index {

    public subscript(safe index: Index) -> Iterator.Element? {
        return (startIndex <= index && index < endIndex) ? self[index] : nil
    }

    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}
