//
//  Repository.swift
//  RCRC
//
//  Created by Ganesh Shinde on 12/08/20.
//

import Foundation

// Generic Base Repository

protocol BaseRepository {

    associatedtype T

    func create(record: T)
    func fetchAll() -> [T]?
    func deleteAll(entity: RCRCoreDataEntity)
}
