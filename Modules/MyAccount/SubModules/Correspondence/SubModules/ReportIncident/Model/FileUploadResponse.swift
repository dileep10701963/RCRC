//
//  FileUploadModel.swift
//  RCRC
//
//  Created by Ganesh on 30/06/21.
//

import Foundation

// MARK: - UploadResponse
struct FileUploadResponse: Decodable {
    var status, statusMessage, attachmentID, fileName: String?

    enum CodingKeys: String, CodingKey {
        case status, statusMessage
        case attachmentID = "attachmentId"
        case fileName = "FileName"
    }
}
