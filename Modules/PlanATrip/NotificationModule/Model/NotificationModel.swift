//
//  NotificationModel.swift
//  RCRC
//
//  Created by Errol on 08/04/21.
//

import Foundation

struct NotificationModel: Codable {
    var title: String
    var message: String
    var date: String
    var time: String
    var subMessage: String = ""
    var isMessageRead: Bool = false
}
