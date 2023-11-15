//
//  SendEmailModel.swift
//  RCRC
//
//  Created by Ganesh on 30/06/21.
//

import Foundation

struct SendEmailResponse: Decodable {
    var sendEmailAttachment: SendEmailAttachment?
}

// MARK: - SendEmailAttachment
struct SendEmailAttachment: Decodable {
    var emailSentStatus, deleteFileStatus: String?
}
