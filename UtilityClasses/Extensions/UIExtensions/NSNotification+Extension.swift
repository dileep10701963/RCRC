//
//  NSNotification+Extensions.swift
//  RCRC
//
//  Created by Ganesh Shinde on 31/12/20.
//

import Foundation

extension Notification.Name {

    static let DidMapPressed = Notification.Name("MapPressed")

}

extension NSNotification {
    public static let DidMapPressed = Notification.Name.DidMapPressed
}
