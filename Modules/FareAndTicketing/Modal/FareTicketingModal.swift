//
//  FareTicketingModal.swift
//  RCRC
//
//  Created by Aashish Singh on 15/11/22.
//

// MARK: - FairTicketingModel
struct FairTicketModel: Codable {
    let actions: BusModelActions?
    let items: [BusItem]?
    let lastPage, page, pageSize, totalCount: Int?
}
