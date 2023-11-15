//
//  PurchasedPassCellViewModel.swift
//  RCRC
//
//  Created by Errol on 03/08/21.
//

import Foundation

struct PurchasedPassCellViewModel {
    let passDescription: String?
    let passCost: String?
    let passName: String?
    let select: () -> Void

    init(product: FareMediaPurchasedProduct, select: @escaping () -> Void) {
        self.passDescription = (product.profileName?.localized ?? "") + " - " + (product.name?.localized ?? "")
        self.passName = product.name?.localized ?? ""
        self.passCost = product.price?.description ?? "0"
        self.select = select
    }
}
