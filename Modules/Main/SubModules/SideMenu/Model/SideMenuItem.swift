//
//  SideMenuItem.swift
//  RCRC
//
//  Created by Errol on 16/06/21.
//

import Foundation

struct SideMenuItem {
    let name: String
    let icon: String
    let selectedIcon: String
    let viewController: AnyClass?

    init(name: String, icon: String, selectedIcon: String, viewController: AnyClass? = nil) {
        self.name = name
        self.icon = icon
        self.selectedIcon = selectedIcon
        self.viewController = viewController
    }
}
