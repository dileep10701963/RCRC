//
//  PurchaseNewPassCellViewModel.swift
//  RCRC
//
//  Created by Errol on 03/08/21.
//

import Foundation

struct PurchaseNewPassCellViewModel {
    let passDescription: String?
    let passCost: String?
    let select: () -> Void

    init(product: FareMediaAvailableProduct, select: @escaping () -> Void) {
        self.passDescription = product.name?.localized
        self.passCost = product.price?.string.localized
        self.select = select
    }
}
